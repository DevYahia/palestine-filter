import 'dart:io';
import 'dart:ui';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
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
    try {
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
          msg: 'Failed to save image',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Wait for image to load!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  final filterPresets = <FilterPresets>[
    FilterPresets(null, null),
    FilterPresets(Colors.red.withAlpha(150), BlendMode.hardLight),
    FilterPresets(Colors.red[400], BlendMode.darken),
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
                // "https://wallpaperaccess.com/full/1635569.jpg",
                "assets/images/palestine_flag.jpg",
                errorBuilder: (context, error, stackTrace) {
                  Fluttertoast.showToast(
                    msg: 'Failed to load background image',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return Center(child: CircularProgressIndicator());
                },
                // loadingBuilder: (context, child, loadingProgress) {
                //   if (loadingProgress == null) return child;
                //   return Center(
                //     child: CircularProgressIndicator(
                //       value: loadingProgress.expectedTotalBytes != null
                //           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                //           : null,
                //     ),
                //   );
                // },
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
          Material(
            color: Colors.transparent,
            child: Center(
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
                        tr("homeSubtitle"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                      ),
                    ),
                    // body
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // BUTTON: CLOSE
                          if (imgFile != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: CircularIcon(
                                tooltip: tr("homeClear"),
                                iconData: Icons.close,
                                backgroundColor: Colors.grey.withAlpha(100),
                                onTap: () {
                                  setState(() {
                                    imgFile = null;
                                    currentFilter = 0;
                                  });
                                },
                              ),
                            ),
                          // image stuff
                          if (imgFile == null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.0),
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
                                      Icon(Icons.add_a_photo_rounded, size: 40.0),
                                      const SizedBox(height: 8.0),
                                      Text(tr("homeAddPicture")),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              // width: 220,
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
                                      fit: BoxFit.fitHeight,
                                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                        if (wasSynchronouslyLoaded ?? false) {
                                          return child;
                                        }
                                        return AnimatedOpacity(
                                          child: child,
                                          opacity: frame == null ? 0 : 1,
                                          duration: const Duration(seconds: 1),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      color: filterPresets[currentFilter].color,
                                      colorBlendMode: filterPresets[currentFilter].blendMode,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // // BUTTONS: FILTERS
                          if (imgFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: tr("homeNormal"),
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
                                    tooltip: tr("homeFilter") + " 1",
                                    icon: Icon(
                                      currentFilter == 1 ? Icons.check_circle_outline_rounded : Icons.circle,
                                      color: Colors.red[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        currentFilter = 1;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    tooltip: tr("homeFilter") + " 2",
                                    icon: Icon(
                                      currentFilter == 2 ? Icons.check_circle_outline_rounded : Icons.circle,
                                      color: Colors.red[700],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        currentFilter = 2;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    tooltip: tr("homeFilter") + " 3",
                                    icon: Icon(
                                      currentFilter == 3 ? Icons.check_circle_outline_rounded : Icons.circle,
                                      color: Colors.red[900],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        currentFilter = 3;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          // Row of buttons
                          Padding(
                            padding: EdgeInsets.only(top: imgFile != null ? 16.0 : 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // twitter
                                CircularIcon(
                                  tooltip: tr("homeTwitter"),
                                  backgroundColor: Colors.blue,
                                  iconData: CommunityMaterialIcons.twitter,
                                  onTap: () async {
                                    final urlString = "https://www.twitter.com/$TWITTER_HANDLE/";
                                    if (await canLaunch(urlString)) {
                                      launch(urlString);
                                    }
                                  },
                                ),
                                const SizedBox(width: 16.0),
                                // my website
                                CircularIcon(
                                  tooltip: tr("homeMyWebstie"),
                                  backgroundColor: Colors.black,
                                  iconData: CommunityMaterialIcons.link,
                                  onTap: () async {
                                    final urlString = MY_WEBSITE;
                                    if (await canLaunch(urlString)) {
                                      launch(urlString);
                                    }
                                  },
                                ),
                                const SizedBox(width: 16.0),
                                // share
                                CircularIcon(
                                  tooltip: tr("homeShare"),
                                  backgroundColor: Colors.green,
                                  iconData: CommunityMaterialIcons.share_variant,
                                  onTap: () async {
                                    final String messeage = tr("shareMessage") +
                                        ":\n" +
                                        tr("iOS") +
                                        ": $IOS_LINK\n" +
                                        tr("Android") +
                                        ": $ANDROID_LINK";
                                    Share.share(messeage);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: imgFile == null
          ? null
          : FloatingActionButton(
              onPressed: _onCapturePressed,
              tooltip: tr('save'),
              child: Icon(Icons.save),
            ),
    );
  }
}
