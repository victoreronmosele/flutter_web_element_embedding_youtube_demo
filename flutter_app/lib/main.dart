import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData();

    return MaterialApp(
      title: 'Random Image Generator',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          theme.textTheme,
        ),
        appBarTheme: theme.appBarTheme.copyWith(
          titleTextStyle: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int generationCount = 0;
  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState();

    final export = createJSInteropWrapper(this);
    globalContext['_appState'] = export;
  }

  @JSExport()
  void updateButtonEnabledState(bool isEnabledFromJS) {
    setState(() {
      isButtonEnabled = isEnabledFromJS;
    });
  }

  @JSExport()
  void generateRandomImage() {
    setState(() {
      generationCount++;
    });

    globalContext.callMethod('randomImageGenerated'.toJS, generationCount.toJS);
  }

  @JSExport()
  void resetCounter() {
    setState(() {
      generationCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Random Image Generator',
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GeneratedImage(generationCount: generationCount),
                const SizedBox(height: 50),
                GenerationCountText(count: generationCount),
                const SizedBox(height: 20),
                GenerateButton(
                  onPressed: isButtonEnabled ? generateRandomImage : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GenerateButton extends StatelessWidget {
  const GenerateButton({super.key, required this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
      ),
      child: const Text('Generate Random Image'),
    );
  }
}

class GenerationCountText extends StatefulWidget {
  final int count;

  const GenerationCountText({
    super.key,
    required this.count,
  });

  @override
  State<GenerationCountText> createState() => _GenerationCountTextState();
}

class _GenerationCountTextState extends State<GenerationCountText>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${widget.count}',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        )
            .animate(
              controller: AnimationController(vsync: this),
              onComplete: (controller) => controller.dispose(),
            )
            .scaleXY()
            .fadeIn(),
        const SizedBox(height: 8),
        Text(
          'Image${widget.count == 1 ? '' : 's'} Generated',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

class GeneratedImage extends StatelessWidget {
  final int generationCount;

  const GeneratedImage({super.key, required this.generationCount});

  String get imageUrl =>
      'https://picsum.photos/2048/2048?random=$generationCount';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final screenWidth = MediaQuery.of(context).size.width;
    final imageDimension = screenWidth * 0.8;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryColor,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: imageDimension,
      height: imageDimension,
      clipBehavior: Clip.hardEdge,
      child: generationCount == 0
          ? Placeholder(
              color: primaryColor,
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: primaryColor.withOpacity(0.4),
                highlightColor: primaryColor.withOpacity(0.1),
                child: Container(
                  width: imageDimension,
                  height: imageDimension,
                  color: primaryColor,
                ),
              ),
            ),
    );
  }
}
