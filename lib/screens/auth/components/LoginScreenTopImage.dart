import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Adepth",
          style: TextStyle(
              fontWeight: FontWeight.bold,
            color: ColorUtils.primaryColor,
            fontSize: 24
          ),
        ),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 2,
              child: SvgPicture.asset("assets/icons/login.svg"),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}