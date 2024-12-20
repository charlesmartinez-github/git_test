import 'package:finedger/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final List<Map<String, String>> articles = [
    {
      'title': '10 Tips for Building a Strong Financial Foundation',
      'date': '6th May',
      'image': 'images/1.png',
      'url': 'https://www.universalfunding.com/financial-foundation/'
    },
    {
      'title': 'How to Create a Budget That Works for You',
      'date': '6th May',
      'image': 'images/2.png',
      'url': 'https://www.nerdwallet.com/article/finance/how-to-budget'
    },
    {
      'title': 'Understanding Your Credit Score',
      'date': '6th May',
      'image': 'images/3.png',
      'url': 'https://consumer.ftc.gov/articles/understanding-your-credit'
    }
    // Add more articles here
  ];

  // void _launchURL(String url) async {
  //   Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: kBlueColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              width: double.infinity,
              height: 36.0,
              child: const Center(
                child: Text(
                  'Articles',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  Uri uri = Uri.parse(article['url']!);
                  return Link(
                    uri: uri,
                    builder: (context, openLink) => InkWell(
                      onTap: openLink,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                article['image']!,
                                fit: BoxFit.fill,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                article['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(article['date']!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
