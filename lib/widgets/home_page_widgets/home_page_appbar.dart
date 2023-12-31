import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/auth_bloc_events.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/auth_bloc_states.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/authorization_service/google_service/google_service.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/main_auth_bloc.dart';
import 'package:youtube/pages/search_screen/presentation/search_screen.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube/widgets/custom_clipper_helper/custom_clipper_helper.dart';
import 'package:youtube/widgets/image_loader_widget.dart';

// CustomShadowPainterWithClipper
// https://gist.github.com/coman3/e631fd55cd9cdf9bd4efe8ecfdbb85a7
class QuadraticBezierToClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 0);

    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class HomePageAppBar extends StatelessWidget {
  const HomePageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final authBlocStates = context.watch<MainAuthBloc>().state;

      var authBlocStateModel = authBlocStates.authStateModel;

      return CustomerClipperWithShadow(
        clipper: QuadraticBezierToClipper(),
        child: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: const Text("FTube", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => [],
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              ),
              icon: const Icon(
                CupertinoIcons.search,
                color: Colors.black,
              ),
            ),
            if (authBlocStates is LoadingAuthState)
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3)),
              )
            else if (authBlocStates is ErrorAuthState)
              IconButton(
                  onPressed: () => context
                      .read<MainAuthBloc>()
                      .add(LoginEvent(authorizationService: GoogleService())),
                  icon: const Icon(Icons.person))
            else
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                      width: 30,
                      height: 30,
                      child: ImageLoaderWidget(
                          url: authBlocStateModel.user?.imageUrl ?? "",
                          errorImageUrl: 'assets/custom_images/custom_user_image.png')),
                ),
              )
          ],
        ),
      );
    });
  }
}
