import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final double score;

  User(this.name, this.score);

  Map<String, dynamic> toMap() {
    return {
      'Game id': name,
      'Rank': score,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['Game id'],
      map['Rank'],
    );
  }

  @override
  String toString() {
    return 'User{ Game id: $name, Rank: $score}';
  }
}

class Cluster {
  final List<User> users;
  double averageScore;

  Cluster(this.users) : averageScore = _calculateAverageScore(users);

  static double _calculateAverageScore(List<User> users) {
    if (users.isEmpty) {
      return 0;
    }
    double totalScore = users.fold(0, (acc, user) => acc + user.score);
    return totalScore / users.length;
  }

  @override
  String toString() {
    return 'Cluster{users: $users, averageScore: $averageScore}';
  }
}

class UserClusterer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Cluster>> clusterUsers() async {
    // retrieve all users from firestore
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('RandomParticipants').get();

    // convert query snapshot to a list of User objects
    final List<User> allUsers =
        querySnapshot.docs.map((doc) => User.fromMap(doc.data()!)).toList();

    // sort users by score in descending order
    allUsers.sort((a, b) => b.score.compareTo(a.score));

    // create 4 empty clusters
    final List<Cluster> clusters = List.generate(
      4,
      (index) => Cluster([]),
    );

    // add each user to the cluster with the fewest number of users
    final assignedUsers = <User>{};
    for (final user in allUsers) {
      if (assignedUsers.contains(user)) {
        continue; // skip users that have already been assigned to a cluster
      }

      final closestCluster = clusters.reduce(
        (a, b) => a.users.length < b.users.length ? a : b,
      );
      closestCluster.users.add(user);
      assignedUsers.add(user);

      if (closestCluster.users.length >= 5) {
        // remove the assigned users from the remaining list to avoid reassigning them
        assignedUsers.addAll(closestCluster.users);
      }
    }

    // balance clusters by average score
    while (true) {
      // calculate the average score of each cluster
      final List<double> averageScores =
          clusters.map((cluster) => cluster.averageScore).toList();

      // check if all clusters have at least five users
      if (clusters.every((cluster) => cluster.users.length == 5)) {
        // stop balancing clusters
        break;
      }

      // find the cluster with the lowest average score
      final lowestAvgScoreClusterIndex =
          averageScores.indexOf(averageScores.reduce(min));
      final lowestAvgScoreCluster = clusters[lowestAvgScoreClusterIndex];

      // find the cluster with the highest average score
      final highestAvgScoreClusterIndex =
          averageScores.indexOf(averageScores.reduce(max));
      final highestAvgScoreCluster = clusters[highestAvgScoreClusterIndex];

      // check if the highest average score cluster has more than five users
      if (highestAvgScoreCluster.users.length > 5) {
        // find the user with the highest score in the highest average score cluster
        final userToMove = highestAvgScoreCluster.users.reduce(
          (a, b) => a.score < b.score ? b : a,
        );
        highestAvgScoreCluster.users.remove(userToMove);
        lowestAvgScoreCluster.users.add(userToMove);

        // update the average score of the clusters
        lowestAvgScoreCluster.averageScore =
            Cluster._calculateAverageScore(lowestAvgScoreCluster.users);
        highestAvgScoreCluster.averageScore =
            Cluster._calculateAverageScore(highestAvgScoreCluster.users);
      } else {
        // stop balancing clusters
        break;
      }
    }

// display the clusters with users and their scores
    print('Final Clusters:');
    clusters.forEach((cluster) {
      print('Cluster ${clusters.indexOf(cluster)}:');
      cluster.users.forEach((user) {
        print('${user.name} - ${user.score}');
      });
    });

    return clusters;
  }
}
