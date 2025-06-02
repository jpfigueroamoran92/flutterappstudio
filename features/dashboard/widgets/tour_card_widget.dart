import 'package:flutter/material.dart';
import 'package:myapp/models/tour.dart';
import 'package:myapp/shared/app_colors.dart'; 
import 'package:myapp/features/dashboard/screens/tour_detail_screen.dart'; // For navigation
import 'package:share_plus/share_plus.dart'; // For sharing

class TourCardWidget extends StatelessWidget {
  final Tour tour;

  const TourCardWidget({super.key, required this.tour});

  Future<void> _shareLink(BuildContext context, String link, String tourName) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        'Echa un vistazo a este recorrido virtual: $tourName - $link',
        subject: 'Recorrido Virtual: $tourName',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      print('Error al compartir: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al compartir el enlace.'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Adjusted margin
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, 
      child: InkWell( // Make the whole card tappable
        onTap: () {
          Navigator.pushNamed(
            context,
            TourDetailScreen.routeName,
            arguments: tour, // Pass the tour object as an argument
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Image
            (tour.imageUrl != null && tour.imageUrl!.isNotEmpty)
                ? Hero( // Optional: Add Hero animation for image transition
                    tag: 'tour_image_${tour.id}', // Unique tag for Hero
                    child: Image.network(
                      tour.imageUrl!,
                      height: 180, // Slightly increased height
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Container(
                          height: 180,
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey[500], size: 50),
                        );
                      },
                    ),
                  )
                : Container(
                    height: 180,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    alignment: Alignment.center,
                    child: Icon(Icons.vrpano_outlined, color: Colors.grey[500], size: 50),
                  ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  if (tour.address != null && tour.address!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tour.address!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 14, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${tour.viewsCount} visualizaciones',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      // Share button
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppColors.secondaryColor, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        tooltip: 'Compartir Enlace',
                        onPressed: tour.kuulaShareLink.isNotEmpty
                            ? () => _shareLink(context, tour.kuulaShareLink, tour.name)
                            : null,                      
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
