import 'dart:io';
import 'dart:ui';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palestine_filter/models/filter_presets.dart';
import 'package:palestine_filter/shared/constants.dart';
import 'package:palestine_filter/utils/capture.dart';
import 'package:palestine_filter/widgets/circular_icon.dart';
import 'package:palestine_filter/widgets/image_filter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File imgFile;
  double sliderValue = 0.0;

  final _captureKey = GlobalKey<CaptureWidgetState>();
  Future<CaptureResult> _image;

  void _openImg() async {
    var res = await ImagePicker().getImage(source: ImageSource.gallery);
    if (res != null) {
      var imgPath = res.path;
      imgFile = File(imgPath);
      setState(() {});
    }
  }

  void _onCapturePressed() async {
    _image = _captureKey.currentState.captureImage();
    var res = await _image;
    if (await Permission.storage.request().isGranted) {
      final result = await ImageGallerySaver.saveImage(
        res.data,
        quality: 100,
        name: "palestine_filter_${DateTime.now().millisecondsSinceEpoch}",
      );
      Fluttertoast.showToast(
        msg: 'Image saved',
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to save',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  final filterPresets = <FilterPresets>[
    FilterPresets(null, null),
    FilterPresets(Colors.red.withAlpha(150), BlendMode.hardLight),
    FilterPresets(Colors.red, BlendMode.darken),
  ];

  int currentFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: 1,
              child: Image.asset(
                "assets/palestine_flag.jpg",
                fit: BoxFit.cover,
                color: Colors.black.withAlpha(100),
                colorBlendMode: BlendMode.hardLight,
              ),
            ),
          ),
          // BLUR
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.white.withAlpha(1),
              ),
            ),
          ),
          // BODY
          Center(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // title
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // subtitle
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Add an image, then tap on the red circle to apply the red filter.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                    ),
                  ),
                  // space
                  Spacer(),
                  // image stuff
                  if (imgFile == null)
                    GestureDetector(
                      onTap: _openImg,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey[200].withAlpha(150),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image),
                            Text("Tap to add picture"),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: CaptureWidget(
                          key: _captureKey,
                          capture: CustomImageFilter(
                            hue: sliderValue,
                            child: Image.file(
                              imgFile,
                              fit: BoxFit.cover,
                              color: filterPresets[currentFilter].color,
                              colorBlendMode: filterPresets[currentFilter].blendMode,
                            ),
                          ),
                          child: CustomImageFilter(
                            hue: sliderValue,
                            child: Image.file(
                              imgFile,
                              fit: BoxFit.cover,
                              color: filterPresets[currentFilter].color,
                              colorBlendMode: filterPresets[currentFilter].blendMode,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Filters
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // BUTTON: CLEAR
                        if (imgFile != null)
                          IconButton(
                            tooltip: "Clear",
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                imgFile = null;
                                currentFilter = 0;
                              });
                            },
                          ),
                        // BUTTONS: FILTERS
                        if (imgFile != null) ...[
                          IconButton(
                            tooltip: "Normal",
                            icon: Icon(
                              currentFilter == 0 ? Icons.check_circle_outline_rounded : Icons.circle,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                currentFilter = 0;
                              });
                            },
                          ),
                          IconButton(
                            tooltip: "Filter 1",
                            icon: Icon(
                              currentFilter == 1 ? Icons.check_circle_outline_rounded : Icons.circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                currentFilter = 1;
                              });
                            },
                          ),
                          IconButton(
                            tooltip: "Filter 2",
                            icon: Icon(
                              currentFilter == 2 ? Icons.check_circle_outline_rounded : Icons.circle,
                              color: Colors.red[900],
                            ),
                            onPressed: () {
                              setState(() {
                                currentFilter = 2;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Row of buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // twitter
                        CircularIcon(
                          tooltip: "twitter",
                          backgroundColor: Colors.blue,
                          iconData: CommunityMaterialIcons.twitter,
                          onTap: () async {
                            final urlString = "https://www.twitter.com/DevYahia/";
                            if (await canLaunch(urlString)) {
                              launch(urlString);
                            }
                          },
                        ),
                        const SizedBox(width: 16.0),
                        // my website
                        CircularIcon(
                          tooltip: "My Website",
                          backgroundColor: Colors.black,
                          iconData: CommunityMaterialIcons.link,
                          onTap: () async {
                            final urlString = "https://www.devyahia.com/";
                            if (await canLaunch(urlString)) {
                              launch(urlString, forceWebView: true);
                            }
                          },
                        ),
                        const SizedBox(width: 16.0),
                        // share
                        CircularIcon(
                          tooltip: "Share",
                          backgroundColor: Colors.green,
                          iconData: CommunityMaterialIcons.share_variant,
                          onTap: () async {
                            Share.share(
                              "apply Palestine Filter to your images through this app:\nios: $IOS_LINK\nandroid: $ANDROID_LINK",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // space
                  Spacer(),
                  const SizedBox(height: 50.0),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: imgFile == null
          ? null
          : FloatingActionButton(
              onPressed: _onCapturePressed,
              tooltip: 'Save',
              child: Icon(Icons.save),
            ),
    );
  }
}
