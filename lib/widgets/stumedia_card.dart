import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StumediaStoryCard extends StatelessWidget {
  final String title;
  final String author;
  final String readCount;
  final VoidCallback onTap;

  const StumediaStoryCard({
    Key? key,
    required this.title,
    required this.author,
    required this.readCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sol Taraf: Görsel Placeholder
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(Icons.book, color: AppColors.primary, size: 30),
            ),
            // Sağ Taraf: Bilgiler
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Yazar: $author', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye, size: 14, color: AppColors.secondary),
                        SizedBox(width: 4),
                        Text(readCount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}