import 'package:eduplay/screens/home/topics/topic_controller.dart';
import 'package:eduplay/widgets/circular_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/topic_card.dart';

class TopicScreen extends StatelessWidget {
  TopicScreen({super.key});
  final vm = Get.find<TopicController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (vm.isLoading.value) {
            return CircularLoader();
          }
          if (vm.error.value.isNotEmpty) {
            return Text(vm.error.value);
          }

          return ListView.builder(
            itemCount: vm.topics.length,
            itemBuilder: (context, index) {
              final topic = vm.topics[index];
              return TopicCard(
                topic: topic,
                CardtColor: null,
                accentColor: Colors.red,
              );
            },
          );
        }),
      ),
    );
  }
}
