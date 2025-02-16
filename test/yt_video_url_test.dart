import 'package:flutter_test/flutter_test.dart';

void main() {
  final regEx = RegExp('mime=video%2Fmp4');
  final regEx2 = RegExp("ratebypass=yes");

  group('yt-video-uri-test', () {
    test('first_test', () {
      final String url =
          'https://rr2---sn-4g5ednsd.googlevideo.com/videoplayback?expire=1701989661&ei=vfhxZeGyEuWYv_IP85CW-As&ip=109.75.50.13&id=o-AAJYm0YRlf3i_LL6B9Ct8iCHQp81ktnFES2GFnXh72x'
          '0&itag=17&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&vprv=1&mime=video%2F3gpp&gir=yes&clen=33839152&dur=3600.114&lmt=1541266590593496&fexp=24007246&c=ANDROID_TESTSUITE&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cvp'
          'rv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=ANLwegAwRQIgIc0YLFKyQ8SLd5SVfGeek7jpcRMivKbOgp3vS5keLsgCIQDcPeWjNApRce7NDRTsvWZXBnFU_gqhMcgrfAENgSUR8w%3D%3D&cm2rm=sn-poqpbvuw-qt0l7l,sn-n8vdee6&req_id=ab8671db2448a3ee&redirect_counter=2&cms_redirect=yes&cmsv=e&mh=us&'
          'mm=34&mn=sn-4g5ednsd&ms=ltu&mt=1701967947&mv=m&mvi=2&pl=24&lsparams=mh,mm,mn,ms,mv,mvi,pl&lsig=AM8Gb2swRAIgMYC1Xx7brFAzwsAKbSxP-1n50ht3W1pay1HK1imwZiYCICm2f7DaLXA1XsGA5l_wCjl8QyktHWhBygdYImvpAi7g';

      expect(false, regEx.hasMatch(url) && regEx2.hasMatch(url));
    });

    test('second_test', () {
      final String url =
          'https://rr2---sn-poqpbvuw-qt0l.googlevideo.com/videoplayback?expire=1701990418&ei=svtxZYBZyLTS7w-EkLawCw&ip=109.75.50.13&id=o-AJJIdGVqU8FMTr8v5R_Nehid2yTcVXXl6-vZIaB2STn7&itag'
          '=22&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&mh=us&mm=31%2C29&mn=sn-poqpbvuw-qt0l%2Csn-n8v7znze&ms=au%2Crdu&mv=m&mvi=2&pl=24&initcwndbps=83750&vprv=1&mime=video%2Fmp4&cnr=14&ratebypass=yes&dur=3600.068&lmt=1541314069088683&mt=1701967730&fvip=15&fexp=24007246&c='
          'ANDROID_TESTSUITE&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cvprv%2Cmime%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=ANLwegAwRQIgcIRLHEj98TlpaLmDVHTfxqbfANvdKJAhc5tNEHRBCfcCIQDYx6RPiRiCK1QMdrZi3wveW5FfMikdKvFSu4lKRwby-Q%3D%3D&lsparams=mh%2Cmm%2Cmn'
          '%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AM8Gb2swRQIgKmIbkRRHliyvd_'
          '-HO4XnNKf1wvobY70VJlhE1rjEUcACIQCmomv2jh7KeIlPHPUDhOFk8Wpflb9DDkloW-6UqZWiFg%3D%3D';

      expect(true, regEx.hasMatch(url) && regEx2.hasMatch(url));
    });
  });
}
