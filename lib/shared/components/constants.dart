//base(url): https://newsapi.org/
// method(url): v2/top-headlines?
// queries : country=us&category=business&apiKey=16367fed0709431e9ff15c29940e9f7c
//https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=16367fed0709431e9ff15c29940e9f7c

//https://newsapi.org/v2/everything?q=tesla&apiKey=16367fed0709431e9ff15c29940e9f7c

void printFullText(String text) {
  final pattern = RegExp('.{1800}'); // 800 is the size  of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

String? token = '';
String? uId = '';
