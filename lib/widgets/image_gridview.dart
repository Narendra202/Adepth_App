import 'package:cached_network_image/cached_network_image.dart';
import 'package:expedition_poc/widgets/image_viewer.dart';
import 'package:flutter/material.dart';

class ImageGridView extends StatelessWidget {
  final List<String> imageUrls;

  ImageGridView({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150, // Specify the desired height here
      child: GridView.builder(
        itemCount: imageUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImageViewer(imageUrl: imageUrls[index]),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              placeholder: (context, url) => Container(
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 30.0, // Adjust the size of the CircularProgressIndicator here
                  height: 30.0, // Adjust the size of the CircularProgressIndicator here
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }
}
