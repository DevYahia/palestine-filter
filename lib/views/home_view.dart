import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palestine_filter/models/filter_presets.dart';
import 'package:palestine_filter/shared/constants.dart';
import 'package:palestine_filter/utils/capture.dart';
import 'package:palestine_filter/utils/color_filter.dart';
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
          // BODY
          Center(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 32.0),
                  // title
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headline5.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                          capture: imageFilter(
                            hue: sliderValue,
                            child: Image.file(
                              imgFile,
                              fit: BoxFit.cover,
                              color: filterPresets[currentFilter].color,
                              colorBlendMode: filterPresets[currentFilter].blendMode,
                            ),
                          ),
                          child: imageFilter(
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
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      if (imgFile != null) ...[
                        IconButton(
                          tooltip: "Normal",
                          icon: Icon(Icons.circle, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              currentFilter = 0;
                            });
                          },
                        ),
                        IconButton(
                          tooltip: "Filter 1",
                          icon: Icon(Icons.circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              currentFilter = 1;
                            });
                          },
                        ),
                        IconButton(
                          tooltip: "Filter 2",
                          icon: Icon(Icons.circle, color: Colors.red[900]),
                          onPressed: () {
                            setState(() {
                              currentFilter = 2;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                  // space
                  Spacer(),
                  const SizedBox(height: 50.0),
                ],
              ),
            ),
          ),
          //
          Positioned(
            bottom: 100.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    tooltip: "twitter",
                    icon: Icon(CommunityMaterialIcons.twitter, color: Colors.white),
                    onPressed: () async {
                      final urlString = "https://www.twitter.com/DevYahia/";
                      if (await canLaunch(urlString)) {
                        launch(urlString);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: IconButton(
                    tooltip: "My Website",
                    icon: Icon(CommunityMaterialIcons.link, color: Colors.white),
                    onPressed: () async {
                      final urlString = "https://www.devyahia.com/";
                      if (await canLaunch(urlString)) {
                        launch(urlString, forceWebView: true);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    tooltip: "Share",
                    icon: Icon(CommunityMaterialIcons.share_variant, color: Colors.white),
                    onPressed: () async {
                      Share.share(
                        "apply Palestine Filter to your images through this app:\nios: $IOS_LINK\nandroid: $ANDROID_LINK",
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: imgFile == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _onCapturePressed,
              tooltip: 'Save',
              label: Text('Save'),
              icon: Icon(Icons.save),
            ),
    );
  }

  Widget imageFilter({brightness = 0.0, saturation = 0.0, hue, child}) {
    return ColorFiltered(
        colorFilter: ColorFilter.matrix(ColorFilterGenerator.brightnessAdjustMatrix(
          value: brightness,
        )),
        child: ColorFiltered(
            colorFilter: ColorFilter.matrix(ColorFilterGenerator.saturationAdjustMatrix(
              value: saturation,
            )),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(ColorFilterGenerator.hueAdjustMatrix(
                value: hue,
              )),
              child: child,
            )));
  }
}
