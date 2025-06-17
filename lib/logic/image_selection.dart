import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:voiced/logic/main_ai_query.dart';
import 'package:voiced/support_files/constants.dart';
import '../providers/locale_provider.dart';
import 'text_to_speech_function.dart';


class ImageSelection extends StatefulWidget {
  const ImageSelection({super.key});

  @override
  State<ImageSelection> createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<ImageSelection> {
  late TextToSpeechFunc textToSpeech;
  File? image;
  final picker = ImagePicker();
  bool responseComplete = false;
  String responseTextValue = '';
  bool _isAnimating = true;
  String languageCode = 'en_GB';

  void setLanguageCode() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false).locale;
    setState(() => languageCode = localeProvider.toString());
    debugPrint('Language code at imageSelection: $languageCode');
  }

  void _toggleVisibility() {
    setState(() {
      _isAnimating = !_isAnimating;
    });
  }


  Future _selectImage() async {
    try {
      //TODO: Change image source back to camera after film made
      final selectedImage = await picker.pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() {
          _saveImageAndInitialize(selectedImage);
          _toggleVisibility();
        });
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } on Exception catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            backgroundColor: kAlertDialogBackground,
            title: const Text('Error'),
            content: const Text('We need permission to access your photos'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Grant Permission'),
                onPressed: () async {
                  Navigator.pop(context);
                  final status = await Permission.photos.request();
                  if (status.isGranted) {
                    _selectImage();
                  } else {
                    Fluttertoast.showToast(
                      msg: 'You will need to use your camera',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ],
          ),
        );
      } else {
        debugPrint('Error in _updateResponseWithQuestion: $error');
      }
    }
  }

  Future<void> _saveImageAndInitialize(XFile pickedImage) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedImage.path);
    final savedImagePath = '${appDir.path}/$fileName';
    final savedImage = await File(pickedImage.path).copy(savedImagePath);

    setState(() {
      image = savedImage;
    });
    final tempDir = await getTemporaryDirectory();
    final compressedImagePath = '${tempDir.path}/compressed_$fileName';
    var result = await FlutterImageCompress.compressAndGetFile(
      savedImagePath,
      compressedImagePath,
      quality: 60,
      format: CompressFormat.jpeg,
    );
    if (result == null) {
      debugPrint('Image compression failed');
      return;
    }
    File compressedImageFile = File(result.path);
    MainAiQuery mainAiQuery = MainAiQuery(
        imageFile: compressedImageFile, languageCode: languageCode,

        onResponseComplete: (String? responseText) {
          setState(() {
            debugPrint('Response = $responseText');
            responseComplete = true;
            if (responseText != null) {
              responseTextValue = responseText;
            }
          });
        });
    mainAiQuery.initializeVertex(compressedImageFile);
  }

  @override
  void initState() {
    super.initState();
    debugPrint('ImageSelection: initState called');
    debugPrint('ImageSelection: calling setLanguageCode');
    setLanguageCode();
    debugPrint('ImageSelection: calling _selectImage');
    _selectImage();
    debugPrint('ImageSelection: initializing textToSpeech');
    textToSpeech = TextToSpeechFunc(context);
    debugPrint('ImageSelection: initState finished');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kBackgroundTint,
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: height * 0.001, horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 70,
                decoration: const BoxDecoration(
                    color: kDarkBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(48.0),
                      topRight: Radius.circular(22.0),
                      bottomLeft: Radius.circular(48.0),
                      bottomRight: Radius.circular(22.0),
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(35), color: kBackgroundTint),
                        child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: kDarkOrange,
                              size: 54,
                            )),

                      ),
                      const SizedBox(width: 12.0),
                      Text(translate('select_image_screen.top_nav_back'),
                        style: kBasicTextAlt.copyWith(fontSize: 34, color: kBackgroundTint),),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              responseComplete ?
              Column(
                children: [
                  SizedBox(
                    width: width,
                    height: height * 0.78,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          translate('select_image_screen.ready_text'),
                          style: kBasicTextAlt,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            if(textToSpeech.isSpeakingNotifier.value) {
                              await textToSpeech.pauseTts();
                            } else if (textToSpeech.isTtsInitialized && textToSpeech.isPaused) {
                              await textToSpeech.speakText(responseTextValue);
                            } else {
                              textToSpeech.updateText(responseTextValue);
                              await textToSpeech.initializeTts();
                            }
                          },
                          child: Container(
                            height: width * 0.86,
                            width: width * 0.86,
                            decoration: BoxDecoration(
                                color: kDarkOrange,
                                borderRadius: BorderRadius.circular(22.0)
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 240,
                                width: 240,
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: textToSpeech.isSpeakingNotifier,
                                  builder: (context, isPlaying, _) {
                                    return Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(120),
                                        color: isPlaying
                                            ? kDarkBlue
                                            : textToSpeech.isPaused
                                            ? kDarkBlue
                                            : kBackgroundTint,
                                      ),
                                      child: Icon(
                                        isPlaying
                                            ? Icons.pause_rounded
                                            : textToSpeech.isPaused
                                            ? Icons.restart_alt_rounded
                                            : Icons.play_arrow_rounded,
                                        color: kDarkOrange,
                                        size: 240,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        //Display the text pop-up
                        const SizedBox(height: 32.0,),
                        GestureDetector(
                          onTap: () {
                            debugPrint('pressed');
                            showModalBottomSheet(backgroundColor: kDarkBlue,
                              useSafeArea: false,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.0))),
                              barrierColor: kDarkOrange,
                              context: context,
                              builder: (context) => SizedBox(
                                height: height * 0.8,
                                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 22.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: ScrollbarTheme(
                                            data: ScrollbarThemeData(
                                              thumbColor: WidgetStateProperty.all<Color>(kDarkOrange),
                                              trackColor: WidgetStateProperty.all<Color>(Colors.white),
                                              trackBorderColor: WidgetStateProperty.all<Color>(kDarkOrange),
                                              radius: const Radius.circular(12.0),
                                            ),
                                            child: Scrollbar(
                                              thickness: 12.0,
                                              child: SingleChildScrollView(
                                                padding: const EdgeInsets.only(right: 16.0),
                                                child: Text(
                                                  responseTextValue,
                                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )),

                                      Column(
                                        children: [
                                          const SizedBox(height: 16.0,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const SizedBox(width: 10.0),
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      height: 56,
                                                      width: 180,
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), border: Border.all(color: kDarkOrange, width: 2.0)),
                                                    ),
                                                    TextButton.icon(
                                                        icon: const Icon(
                                                            Icons.close_rounded, color: kDarkOrange, size: 34.0, weight: 900
                                                        ),
                                                        onPressed: () => Navigator.pop(context),
                                                        label:  Text(translate('select_image_screen.close_button'),
                                                          style: const TextStyle(color: kDarkOrange, fontSize: 24, letterSpacing: 1.6),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: width,
                            decoration: BoxDecoration(
                              color: kDarkBlue,
                              borderRadius: BorderRadius.circular(22.0)
                          ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 22.0),
                              child: Text(translate('select_image_screen.show_text_btn'),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ) : Column(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    opacity: _isAnimating ? 1.0 : 0.2,
                    child:  Text(
                      translate('select_image_screen.working_text'),
                      style: kBasicTextAlt,
                    ),
                    onEnd: () {
                      setState(() => _isAnimating = !_isAnimating,);
                    },
                  ),
                  const SpinKitThreeBounce(
                    color: kDarkOrange,
                    size: 66.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
