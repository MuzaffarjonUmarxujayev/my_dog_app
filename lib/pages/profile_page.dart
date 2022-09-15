import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/network_service.dart';
import '../services/util_service.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final int crossAxisCount;
  const ProfilePage({Key? key, this.crossAxisCount = 2}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  File? file;
  CameraDevice? device;
  final ImagePicker _picker = ImagePicker();
  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  void _getImage(){
    showModalBottomSheet(context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: _gallery,
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: _camera,
              ),
            ],
          ),
        )
    );
  }


  void _gallery() async{
    Navigator.of(context).pop();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      file = File(image.path);
    }
    setState(() {});
  }

  void _camera() async {
    Navigator.of(context).pop();
    final XFile? cameraImg = await _picker.pickImage(source: ImageSource.camera);
    if(cameraImg != null){
      file = File(cameraImg.path);
    }
    setState(() {});
  }

  void _clear()async {
    file = null;
    setState(() {});
  }


  void _upload() async {
    String subId = controller.text.trim();
    if(subId.isEmpty || file == null){
      Util.fireSnackBar("Please upload image or enter title!", context);
      return;
    }

    isLoading = true;
    setState(() {});

    String? resultUpload = await NetworkService.MULTIPART(NetworkService.API_IMAGE_UPLOAD, file!.path, NetworkService.bodyImageUpload(subId));

    isLoading = false;
    setState(() {});


    if(resultUpload != null){
      if(mounted){
        Util.fireSnackBar("Your image was successfully uploaded!", context);
      }
      controller.clear();
      file = null;
      if(mounted){
        Navigator.pushReplacement(context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomePage(
              crossAxisCount: widget.crossAxisCount,
              subPage: 1,
            ),
            reverseTransitionDuration: const Duration(seconds: 0),
          ),
        );
      }
    }else{
      if(mounted){
        Util.fireSnackBar("Failed! Please try again! System error! ",
            context);
      }
    }
  }

  void _clearTitle(){
    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              onPressed: _upload,
              child: const Text("Upload",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(onPressed: _clear,
                    splashRadius: 25,
                    icon:  const Icon(Icons.clear, color: Colors.black, size: 30,),
                  ),
                  const SizedBox(width: 20,)
                ],
              ),

              Expanded(
                flex: 2,
                child: Center(
                  child: GestureDetector(
                    onTap: _getImage,
                    child:file == null ? Container(
                      alignment: const Alignment(0, 0.35),
                      constraints: const BoxConstraints(
                        minWidth: 250,
                        minHeight: 250,
                        maxHeight: 400,
                        maxWidth: 400,
                      ),
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/img.png"),
                          )
                      ),
                      child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 80,),
                    )
                        : Container(
                      constraints: const BoxConstraints(
                        minWidth: 250,
                        minHeight: 250,
                        maxHeight: 400,
                        maxWidth: 400,
                      ),
                      child: Image.file(
                        file!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child:  TextField(
                    controller: controller,
                    decoration:  InputDecoration(
                      hintText: "Title",
                      suffix: IconButton(
                        onPressed: _clearTitle,
                        splashRadius: 25,
                        icon:const Icon(Icons.clear, color: Colors.black,size: 25,),),
                    ),
                    style:const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
              visible: isLoading,
              child:const Center(child: CircularProgressIndicator(),))
        ],
      ),
    );
  }
}