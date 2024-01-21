


import 'package:flutter/material.dart';
import 'package:oers/backend/comparision.dart';



import '../../backend/clustering.dart';
import '../../widgets/round_button.dart';

class ClusterPage extends StatefulWidget {
  @override
  _ClusterPageState createState() => _ClusterPageState();
}

class _ClusterPageState extends State<ClusterPage> {
  List<Cluster> _clusters = [];

  @override
  void initState() {
    super.initState();
    _clusterUsers();
  }

  Future<void> _clusterUsers() async {
    final userClusterer = UserClusterer();
    final clusters = await userClusterer.clusterUsers();
    setState(() {
      _clusters = clusters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('versus')),
      ),
      body: _buildBody(),

    );
  }

  Widget _buildBody() {
    if (_clusters.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return GridView.builder(

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,childAspectRatio: (100/230)
        ),
        itemCount: _clusters.length,
        itemBuilder: (context, index) {
          final cluster = _clusters[index];
          return Card(
            child: ExpansionTile(
              title: Text('Team ${index + 1}'),

              children: _buildUserList(cluster),
            ),
          );
        },
      );
    }
  }


  List<Widget> _buildUserList(Cluster cluster) {
    if (cluster.users.isEmpty) {
      return [
        ListTile(
          title: Text('No users found'),
        )
      ];
    } else {
      return cluster.users
          .map((user) => ListTile(
        title: Text(user.name),
        subtitle: Text('Rank: ${user.score}'),
      ))
          .toList();
    }

  }
}
