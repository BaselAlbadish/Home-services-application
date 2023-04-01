import 'package:booking_system_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../component/cached_image_widget.dart';
import '../../../component/disabled_rating_bar_widget.dart';
import '../../../component/price_widget.dart';
import '../../../model/provider_for_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/images.dart';
import '../../service/service_detail_screen.dart';
import '../../zoom_image_screen.dart';

class ProviderWidget extends StatefulWidget {
  final Data data;
  final int serviceId;

  const ProviderWidget({required this.serviceId, required this.data, Key? key}) : super(key: key);

  @override
  State<ProviderWidget> createState() => _ProviderWidgetState();
}

class _ProviderWidgetState extends State<ProviderWidget> {
  Widget buildText(String text) {
    return Text(text.validate(), style: primaryTextStyle(), maxLines: 3, overflow: TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          hideKeyboard(context);
          ServiceDetailScreen(
            serviceId: widget.serviceId.validate(),
            providerId: widget.data.providerId.validate(),
          ).launch(context);
        },
        child: Stack(
          children: [
            Container(
              decoration: boxDecorationDefault(
                  color: Color(0xffefdecb),
                  borderRadius: radiusOnly(
                      topRight: appStore.isAr() ? 0.0 : 12.0,
                      topLeft: !appStore.isAr() ? 0.0 : 12.0,
                      bottomRight: appStore.isAr() ? 0.0 : 12.0,
                      bottomLeft: !appStore.isAr() ? 0.0 : 12.0
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        child: CachedImageWidget(
                          url: widget.data.providerImage.validate(),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ).onTap(() {
                          if (widget.data.providerImage.validate().isNotEmpty)
                            ZoomImageScreen(
                              galleryImages: [widget.data.providerImage.validate()],
                              index: 0,
                            ).launch(context);
                        }),
                      ),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text( widget.data.providerName.validate(),
                                  style: boldTextStyle())
                                  .flexible(),
                            ],
                          ),
                          4.height,
                          // DisabledRatingBarWidget(rating: widget.data.providersServiceRating.validate()),
                        ],
                      ).expand(),
                      // Padding(
                      //   padding: EdgeInsets.all(16),
                      //   child: Image.asset(ic_verified, height: 24, width: 24, color: verifyAcColor)
                      //       .visible(widget.data.isVerifyProvider == 1),
                      // ),
                    ],
                  ),
                  // if (widget.data.description.validate().isNotEmpty)
                  //   Padding(
                  //     padding: EdgeInsets.all(16),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         buildText('${widget.data.description.validate()}'),
                  //       ],
                  //     ),
                  //   ),
                ],
              ),
            ).paddingAll(16),
            // Positioned(
            //   top: 8,
            //   right: 25,
            //   child: Container(
            //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //     decoration: boxDecorationWithShadow(
            //       backgroundColor: primaryColor,
            //       borderRadius: radius(24),
            //       border: Border.all(color: context.cardColor, width: 2),
            //     ),
            //     child: PriceWidget(
            //       price: widget.providerForService.price.validate(),
            //       color: Colors.white,
            //       size: 14,
            //     ),
            //   ),
            // ),
          ],
        ));
  }
}