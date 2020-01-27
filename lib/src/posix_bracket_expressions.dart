// copied from https://github.com/diaspora/diaspora/blob/develop/lib/assets/javascripts/posix-bracket-expressions.js

// source: https://github.com/ruby/ruby/blob/ruby_2_4/enc/unicode/9.0.0/name2ctype.h#L3544
const word = r'\u0030-\u0039' +
      r'\u0041-\u005a' +
      r'\u005f-\u005f' +
      r'\u0061-\u007a' +
      r'\u00aa-\u00aa' +
      r'\u00b5-\u00b5' +
      r'\u00ba-\u00ba' +
      r'\u00c0-\u00d6' +
      r'\u00d8-\u00f6' +
      r'\u00f8-\u02c1' +
      r'\u02c6-\u02d1' +
      r'\u02e0-\u02e4' +
      r'\u02ec-\u02ec' +
      r'\u02ee-\u02ee' +
      r'\u0300-\u0374' +
      r'\u0376-\u0377' +
      r'\u037a-\u037d' +
      r'\u037f-\u037f' +
      r'\u0386-\u0386' +
      r'\u0388-\u038a' +
      r'\u038c-\u038c' +
      r'\u038e-\u03a1' +
      r'\u03a3-\u03f5' +
      r'\u03f7-\u0481' +
      r'\u0483-\u052f' +
      r'\u0531-\u0556' +
      r'\u0559-\u0559' +
      r'\u0561-\u0587' +
      r'\u0591-\u05bd' +
      r'\u05bf-\u05bf' +
      r'\u05c1-\u05c2' +
      r'\u05c4-\u05c5' +
      r'\u05c7-\u05c7' +
      r'\u05d0-\u05ea' +
      r'\u05f0-\u05f2' +
      r'\u0610-\u061a' +
      r'\u0620-\u0669' +
      r'\u066e-\u06d3' +
      r'\u06d5-\u06dc' +
      r'\u06df-\u06e8' +
      r'\u06ea-\u06fc' +
      r'\u06ff-\u06ff' +
      r'\u0710-\u074a' +
      r'\u074d-\u07b1' +
      r'\u07c0-\u07f5' +
      r'\u07fa-\u07fa' +
      r'\u0800-\u082d' +
      r'\u0840-\u085b' +
      r'\u08a0-\u08b4' +
      r'\u08b6-\u08bd' +
      r'\u08d4-\u08e1' +
      r'\u08e3-\u0963' +
      r'\u0966-\u096f' +
      r'\u0971-\u0983' +
      r'\u0985-\u098c' +
      r'\u098f-\u0990' +
      r'\u0993-\u09a8' +
      r'\u09aa-\u09b0' +
      r'\u09b2-\u09b2' +
      r'\u09b6-\u09b9' +
      r'\u09bc-\u09c4' +
      r'\u09c7-\u09c8' +
      r'\u09cb-\u09ce' +
      r'\u09d7-\u09d7' +
      r'\u09dc-\u09dd' +
      r'\u09df-\u09e3' +
      r'\u09e6-\u09f1' +
      r'\u0a01-\u0a03' +
      r'\u0a05-\u0a0a' +
      r'\u0a0f-\u0a10' +
      r'\u0a13-\u0a28' +
      r'\u0a2a-\u0a30' +
      r'\u0a32-\u0a33' +
      r'\u0a35-\u0a36' +
      r'\u0a38-\u0a39' +
      r'\u0a3c-\u0a3c' +
      r'\u0a3e-\u0a42' +
      r'\u0a47-\u0a48' +
      r'\u0a4b-\u0a4d' +
      r'\u0a51-\u0a51' +
      r'\u0a59-\u0a5c' +
      r'\u0a5e-\u0a5e' +
      r'\u0a66-\u0a75' +
      r'\u0a81-\u0a83' +
      r'\u0a85-\u0a8d' +
      r'\u0a8f-\u0a91' +
      r'\u0a93-\u0aa8' +
      r'\u0aaa-\u0ab0' +
      r'\u0ab2-\u0ab3' +
      r'\u0ab5-\u0ab9' +
      r'\u0abc-\u0ac5' +
      r'\u0ac7-\u0ac9' +
      r'\u0acb-\u0acd' +
      r'\u0ad0-\u0ad0' +
      r'\u0ae0-\u0ae3' +
      r'\u0ae6-\u0aef' +
      r'\u0af9-\u0af9' +
      r'\u0b01-\u0b03' +
      r'\u0b05-\u0b0c' +
      r'\u0b0f-\u0b10' +
      r'\u0b13-\u0b28' +
      r'\u0b2a-\u0b30' +
      r'\u0b32-\u0b33' +
      r'\u0b35-\u0b39' +
      r'\u0b3c-\u0b44' +
      r'\u0b47-\u0b48' +
      r'\u0b4b-\u0b4d' +
      r'\u0b56-\u0b57' +
      r'\u0b5c-\u0b5d' +
      r'\u0b5f-\u0b63' +
      r'\u0b66-\u0b6f' +
      r'\u0b71-\u0b71' +
      r'\u0b82-\u0b83' +
      r'\u0b85-\u0b8a' +
      r'\u0b8e-\u0b90' +
      r'\u0b92-\u0b95' +
      r'\u0b99-\u0b9a' +
      r'\u0b9c-\u0b9c' +
      r'\u0b9e-\u0b9f' +
      r'\u0ba3-\u0ba4' +
      r'\u0ba8-\u0baa' +
      r'\u0bae-\u0bb9' +
      r'\u0bbe-\u0bc2' +
      r'\u0bc6-\u0bc8' +
      r'\u0bca-\u0bcd' +
      r'\u0bd0-\u0bd0' +
      r'\u0bd7-\u0bd7' +
      r'\u0be6-\u0bef' +
      r'\u0c00-\u0c03' +
      r'\u0c05-\u0c0c' +
      r'\u0c0e-\u0c10' +
      r'\u0c12-\u0c28' +
      r'\u0c2a-\u0c39' +
      r'\u0c3d-\u0c44' +
      r'\u0c46-\u0c48' +
      r'\u0c4a-\u0c4d' +
      r'\u0c55-\u0c56' +
      r'\u0c58-\u0c5a' +
      r'\u0c60-\u0c63' +
      r'\u0c66-\u0c6f' +
      r'\u0c80-\u0c83' +
      r'\u0c85-\u0c8c' +
      r'\u0c8e-\u0c90' +
      r'\u0c92-\u0ca8' +
      r'\u0caa-\u0cb3' +
      r'\u0cb5-\u0cb9' +
      r'\u0cbc-\u0cc4' +
      r'\u0cc6-\u0cc8' +
      r'\u0cca-\u0ccd' +
      r'\u0cd5-\u0cd6' +
      r'\u0cde-\u0cde' +
      r'\u0ce0-\u0ce3' +
      r'\u0ce6-\u0cef' +
      r'\u0cf1-\u0cf2' +
      r'\u0d01-\u0d03' +
      r'\u0d05-\u0d0c' +
      r'\u0d0e-\u0d10' +
      r'\u0d12-\u0d3a' +
      r'\u0d3d-\u0d44' +
      r'\u0d46-\u0d48' +
      r'\u0d4a-\u0d4e' +
      r'\u0d54-\u0d57' +
      r'\u0d5f-\u0d63' +
      r'\u0d66-\u0d6f' +
      r'\u0d7a-\u0d7f' +
      r'\u0d82-\u0d83' +
      r'\u0d85-\u0d96' +
      r'\u0d9a-\u0db1' +
      r'\u0db3-\u0dbb' +
      r'\u0dbd-\u0dbd' +
      r'\u0dc0-\u0dc6' +
      r'\u0dca-\u0dca' +
      r'\u0dcf-\u0dd4' +
      r'\u0dd6-\u0dd6' +
      r'\u0dd8-\u0ddf' +
      r'\u0de6-\u0def' +
      r'\u0df2-\u0df3' +
      r'\u0e01-\u0e3a' +
      r'\u0e40-\u0e4e' +
      r'\u0e50-\u0e59' +
      r'\u0e81-\u0e82' +
      r'\u0e84-\u0e84' +
      r'\u0e87-\u0e88' +
      r'\u0e8a-\u0e8a' +
      r'\u0e8d-\u0e8d' +
      r'\u0e94-\u0e97' +
      r'\u0e99-\u0e9f' +
      r'\u0ea1-\u0ea3' +
      r'\u0ea5-\u0ea5' +
      r'\u0ea7-\u0ea7' +
      r'\u0eaa-\u0eab' +
      r'\u0ead-\u0eb9' +
      r'\u0ebb-\u0ebd' +
      r'\u0ec0-\u0ec4' +
      r'\u0ec6-\u0ec6' +
      r'\u0ec8-\u0ecd' +
      r'\u0ed0-\u0ed9' +
      r'\u0edc-\u0edf' +
      r'\u0f00-\u0f00' +
      r'\u0f18-\u0f19' +
      r'\u0f20-\u0f29' +
      r'\u0f35-\u0f35' +
      r'\u0f37-\u0f37' +
      r'\u0f39-\u0f39' +
      r'\u0f3e-\u0f47' +
      r'\u0f49-\u0f6c' +
      r'\u0f71-\u0f84' +
      r'\u0f86-\u0f97' +
      r'\u0f99-\u0fbc' +
      r'\u0fc6-\u0fc6' +
      r'\u1000-\u1049' +
      r'\u1050-\u109d' +
      r'\u10a0-\u10c5' +
      r'\u10c7-\u10c7' +
      r'\u10cd-\u10cd' +
      r'\u10d0-\u10fa' +
      r'\u10fc-\u1248' +
      r'\u124a-\u124d' +
      r'\u1250-\u1256' +
      r'\u1258-\u1258' +
      r'\u125a-\u125d' +
      r'\u1260-\u1288' +
      r'\u128a-\u128d' +
      r'\u1290-\u12b0' +
      r'\u12b2-\u12b5' +
      r'\u12b8-\u12be' +
      r'\u12c0-\u12c0' +
      r'\u12c2-\u12c5' +
      r'\u12c8-\u12d6' +
      r'\u12d8-\u1310' +
      r'\u1312-\u1315' +
      r'\u1318-\u135a' +
      r'\u135d-\u135f' +
      r'\u1380-\u138f' +
      r'\u13a0-\u13f5' +
      r'\u13f8-\u13fd' +
      r'\u1401-\u166c' +
      r'\u166f-\u167f' +
      r'\u1681-\u169a' +
      r'\u16a0-\u16ea' +
      r'\u16ee-\u16f8' +
      r'\u1700-\u170c' +
      r'\u170e-\u1714' +
      r'\u1720-\u1734' +
      r'\u1740-\u1753' +
      r'\u1760-\u176c' +
      r'\u176e-\u1770' +
      r'\u1772-\u1773' +
      r'\u1780-\u17d3' +
      r'\u17d7-\u17d7' +
      r'\u17dc-\u17dd' +
      r'\u17e0-\u17e9' +
      r'\u180b-\u180d' +
      r'\u1810-\u1819' +
      r'\u1820-\u1877' +
      r'\u1880-\u18aa' +
      r'\u18b0-\u18f5' +
      r'\u1900-\u191e' +
      r'\u1920-\u192b' +
      r'\u1930-\u193b' +
      r'\u1946-\u196d' +
      r'\u1970-\u1974' +
      r'\u1980-\u19ab' +
      r'\u19b0-\u19c9' +
      r'\u19d0-\u19d9' +
      r'\u1a00-\u1a1b' +
      r'\u1a20-\u1a5e' +
      r'\u1a60-\u1a7c' +
      r'\u1a7f-\u1a89' +
      r'\u1a90-\u1a99' +
      r'\u1aa7-\u1aa7' +
      r'\u1ab0-\u1abe' +
      r'\u1b00-\u1b4b' +
      r'\u1b50-\u1b59' +
      r'\u1b6b-\u1b73' +
      r'\u1b80-\u1bf3' +
      r'\u1c00-\u1c37' +
      r'\u1c40-\u1c49' +
      r'\u1c4d-\u1c7d' +
      r'\u1c80-\u1c88' +
      r'\u1cd0-\u1cd2' +
      r'\u1cd4-\u1cf6' +
      r'\u1cf8-\u1cf9' +
      r'\u1d00-\u1df5' +
      r'\u1dfb-\u1f15' +
      r'\u1f18-\u1f1d' +
      r'\u1f20-\u1f45' +
      r'\u1f48-\u1f4d' +
      r'\u1f50-\u1f57' +
      r'\u1f59-\u1f59' +
      r'\u1f5b-\u1f5b' +
      r'\u1f5d-\u1f5d' +
      r'\u1f5f-\u1f7d' +
      r'\u1f80-\u1fb4' +
      r'\u1fb6-\u1fbc' +
      r'\u1fbe-\u1fbe' +
      r'\u1fc2-\u1fc4' +
      r'\u1fc6-\u1fcc' +
      r'\u1fd0-\u1fd3' +
      r'\u1fd6-\u1fdb' +
      r'\u1fe0-\u1fec' +
      r'\u1ff2-\u1ff4' +
      r'\u1ff6-\u1ffc' +
      r'\u203f-\u2040' +
      r'\u2054-\u2054' +
      r'\u2071-\u2071' +
      r'\u207f-\u207f' +
      r'\u2090-\u209c' +
      r'\u20d0-\u20f0' +
      r'\u2102-\u2102' +
      r'\u2107-\u2107' +
      r'\u210a-\u2113' +
      r'\u2115-\u2115' +
      r'\u2119-\u211d' +
      r'\u2124-\u2124' +
      r'\u2126-\u2126' +
      r'\u2128-\u2128' +
      r'\u212a-\u212d' +
      r'\u212f-\u2139' +
      r'\u213c-\u213f' +
      r'\u2145-\u2149' +
      r'\u214e-\u214e' +
      r'\u2160-\u2188' +
      r'\u24b6-\u24e9' +
      r'\u2c00-\u2c2e' +
      r'\u2c30-\u2c5e' +
      r'\u2c60-\u2ce4' +
      r'\u2ceb-\u2cf3' +
      r'\u2d00-\u2d25' +
      r'\u2d27-\u2d27' +
      r'\u2d2d-\u2d2d' +
      r'\u2d30-\u2d67' +
      r'\u2d6f-\u2d6f' +
      r'\u2d7f-\u2d96' +
      r'\u2da0-\u2da6' +
      r'\u2da8-\u2dae' +
      r'\u2db0-\u2db6' +
      r'\u2db8-\u2dbe' +
      r'\u2dc0-\u2dc6' +
      r'\u2dc8-\u2dce' +
      r'\u2dd0-\u2dd6' +
      r'\u2dd8-\u2dde' +
      r'\u2de0-\u2dff' +
      r'\u2e2f-\u2e2f' +
      r'\u3005-\u3007' +
      r'\u3021-\u302f' +
      r'\u3031-\u3035' +
      r'\u3038-\u303c' +
      r'\u3041-\u3096' +
      r'\u3099-\u309a' +
      r'\u309d-\u309f' +
      r'\u30a1-\u30fa' +
      r'\u30fc-\u30ff' +
      r'\u3105-\u312d' +
      r'\u3131-\u318e' +
      r'\u31a0-\u31ba' +
      r'\u31f0-\u31ff' +
      r'\u3400-\u4db5' +
      r'\u4e00-\u9fd5' +
      r'\ua000-\ua48c' +
      r'\ua4d0-\ua4fd' +
      r'\ua500-\ua60c' +
      r'\ua610-\ua62b' +
      r'\ua640-\ua672' +
      r'\ua674-\ua67d' +
      r'\ua67f-\ua6f1' +
      r'\ua717-\ua71f' +
      r'\ua722-\ua788' +
      r'\ua78b-\ua7ae' +
      r'\ua7b0-\ua7b7' +
      r'\ua7f7-\ua827' +
      r'\ua840-\ua873' +
      r'\ua880-\ua8c5' +
      r'\ua8d0-\ua8d9' +
      r'\ua8e0-\ua8f7' +
      r'\ua8fb-\ua8fb' +
      r'\ua8fd-\ua8fd' +
      r'\ua900-\ua92d' +
      r'\ua930-\ua953' +
      r'\ua960-\ua97c' +
      r'\ua980-\ua9c0' +
      r'\ua9cf-\ua9d9' +
      r'\ua9e0-\ua9fe' +
      r'\uaa00-\uaa36' +
      r'\uaa40-\uaa4d' +
      r'\uaa50-\uaa59' +
      r'\uaa60-\uaa76' +
      r'\uaa7a-\uaac2' +
      r'\uaadb-\uaadd' +
      r'\uaae0-\uaaef' +
      r'\uaaf2-\uaaf6' +
      r'\uab01-\uab06' +
      r'\uab09-\uab0e' +
      r'\uab11-\uab16' +
      r'\uab20-\uab26' +
      r'\uab28-\uab2e' +
      r'\uab30-\uab5a' +
      r'\uab5c-\uab65' +
      r'\uab70-\uabea' +
      r'\uabec-\uabed' +
      r'\uabf0-\uabf9' +
      r'\uac00-\ud7a3' +
      r'\ud7b0-\ud7c6' +
      r'\ud7cb-\ud7fb' +
      r'\uf900-\ufa6d' +
      r'\ufa70-\ufad9' +
      r'\ufb00-\ufb06' +
      r'\ufb13-\ufb17' +
      r'\ufb1d-\ufb28' +
      r'\ufb2a-\ufb36' +
      r'\ufb38-\ufb3c' +
      r'\ufb3e-\ufb3e' +
      r'\ufb40-\ufb41' +
      r'\ufb43-\ufb44' +
      r'\ufb46-\ufbb1' +
      r'\ufbd3-\ufd3d' +
      r'\ufd50-\ufd8f' +
      r'\ufd92-\ufdc7' +
      r'\ufdf0-\ufdfb' +
      r'\ufe00-\ufe0f' +
      r'\ufe20-\ufe2f' +
      r'\ufe33-\ufe34' +
      r'\ufe4d-\ufe4f' +
      r'\ufe70-\ufe74' +
      r'\ufe76-\ufefc' +
      r'\uff10-\uff19' +
      r'\uff21-\uff3a' +
      r'\uff3f-\uff3f' +
      r'\uff41-\uff5a' +
      r'\uff66-\uffbe' +
      r'\uffc2-\uffc7' +
      r'\uffca-\uffcf' +
      r'\uffd2-\uffd7' +
      r'\uffda-\uffdc';
  // r'\u10000-\u1000b' +
  // r'\u1000d-\u10026' +
  // r'\u10028-\u1003a' +
  // r'\u1003c-\u1003d' +
  // r'\u1003f-\u1004d' +
  // r'\u10050-\u1005d' +
  // r'\u10080-\u100fa' +
  // r'\u10140-\u10174' +
  // r'\u101fd-\u101fd' +
  // r'\u10280-\u1029c' +
  // r'\u102a0-\u102d0' +
  // r'\u102e0-\u102e0' +
  // r'\u10300-\u1031f' +
  // r'\u10330-\u1034a' +
  // r'\u10350-\u1037a' +
  // r'\u10380-\u1039d' +
  // r'\u103a0-\u103c3' +
  // r'\u103c8-\u103cf' +
  // r'\u103d1-\u103d5' +
  // r'\u10400-\u1049d' +
  // r'\u104a0-\u104a9' +
  // r'\u104b0-\u104d3' +
  // r'\u104d8-\u104fb' +
  // r'\u10500-\u10527' +
  // r'\u10530-\u10563' +
  // r'\u10600-\u10736' +
  // r'\u10740-\u10755' +
  // r'\u10760-\u10767' +
  // r'\u10800-\u10805' +
  // r'\u10808-\u10808' +
  // r'\u1080a-\u10835' +
  // r'\u10837-\u10838' +
  // r'\u1083c-\u1083c' +
  // r'\u1083f-\u10855' +
  // r'\u10860-\u10876' +
  // r'\u10880-\u1089e' +
  // r'\u108e0-\u108f2' +
  // r'\u108f4-\u108f5' +
  // r'\u10900-\u10915' +
  // r'\u10920-\u10939' +
  // r'\u10980-\u109b7' +
  // r'\u109be-\u109bf' +
  // r'\u10a00-\u10a03' +
  // r'\u10a05-\u10a06' +
  // r'\u10a0c-\u10a13' +
  // r'\u10a15-\u10a17' +
  // r'\u10a19-\u10a33' +
  // r'\u10a38-\u10a3a' +
  // r'\u10a3f-\u10a3f' +
  // r'\u10a60-\u10a7c' +
  // r'\u10a80-\u10a9c' +
  // r'\u10ac0-\u10ac7' +
  // r'\u10ac9-\u10ae6' +
  // r'\u10b00-\u10b35' +
  // r'\u10b40-\u10b55' +
  // r'\u10b60-\u10b72' +
  // r'\u10b80-\u10b91' +
  // r'\u10c00-\u10c48' +
  // r'\u10c80-\u10cb2' +
  // r'\u10cc0-\u10cf2' +
  // r'\u11000-\u11046' +
  // r'\u11066-\u1106f' +
  // r'\u1107f-\u110ba' +
  // r'\u110d0-\u110e8' +
  // r'\u110f0-\u110f9' +
  // r'\u11100-\u11134' +
  // r'\u11136-\u1113f' +
  // r'\u11150-\u11173' +
  // r'\u11176-\u11176' +
  // r'\u11180-\u111c4' +
  // r'\u111ca-\u111cc' +
  // r'\u111d0-\u111da' +
  // r'\u111dc-\u111dc' +
  // r'\u11200-\u11211' +
  // r'\u11213-\u11237' +
  // r'\u1123e-\u1123e' +
  // r'\u11280-\u11286' +
  // r'\u11288-\u11288' +
  // r'\u1128a-\u1128d' +
  // r'\u1128f-\u1129d' +
  // r'\u1129f-\u112a8' +
  // r'\u112b0-\u112ea' +
  // r'\u112f0-\u112f9' +
  // r'\u11300-\u11303' +
  // r'\u11305-\u1130c' +
  // r'\u1130f-\u11310' +
  // r'\u11313-\u11328' +
  // r'\u1132a-\u11330' +
  // r'\u11332-\u11333' +
  // r'\u11335-\u11339' +
  // r'\u1133c-\u11344' +
  // r'\u11347-\u11348' +
  // r'\u1134b-\u1134d' +
  // r'\u11350-\u11350' +
  // r'\u11357-\u11357' +
  // r'\u1135d-\u11363' +
  // r'\u11366-\u1136c' +
  // r'\u11370-\u11374' +
  // r'\u11400-\u1144a' +
  // r'\u11450-\u11459' +
  // r'\u11480-\u114c5' +
  // r'\u114c7-\u114c7' +
  // r'\u114d0-\u114d9' +
  // r'\u11580-\u115b5' +
  // r'\u115b8-\u115c0' +
  // r'\u115d8-\u115dd' +
  // r'\u11600-\u11640' +
  // r'\u11644-\u11644' +
  // r'\u11650-\u11659' +
  // r'\u11680-\u116b7' +
  // r'\u116c0-\u116c9' +
  // r'\u11700-\u11719' +
  // r'\u1171d-\u1172b' +
  // r'\u11730-\u11739' +
  // r'\u118a0-\u118e9' +
  // r'\u118ff-\u118ff' +
  // r'\u11ac0-\u11af8' +
  // r'\u11c00-\u11c08' +
  // r'\u11c0a-\u11c36' +
  // r'\u11c38-\u11c40' +
  // r'\u11c50-\u11c59' +
  // r'\u11c72-\u11c8f' +
  // r'\u11c92-\u11ca7' +
  // r'\u11ca9-\u11cb6' +
  // r'\u12000-\u12399' +
  // r'\u12400-\u1246e' +
  // r'\u12480-\u12543' +
  // r'\u13000-\u1342e' +
  // r'\u14400-\u14646' +
  // r'\u16800-\u16a38' +
  // r'\u16a40-\u16a5e' +
  // r'\u16a60-\u16a69' +
  // r'\u16ad0-\u16aed' +
  // r'\u16af0-\u16af4' +
  // r'\u16b00-\u16b36' +
  // r'\u16b40-\u16b43' +
  // r'\u16b50-\u16b59' +
  // r'\u16b63-\u16b77' +
  // r'\u16b7d-\u16b8f' +
  // r'\u16f00-\u16f44' +
  // r'\u16f50-\u16f7e' +
  // r'\u16f8f-\u16f9f' +
  // r'\u16fe0-\u16fe0' +
  // r'\u17000-\u187ec' +
  // r'\u18800-\u18af2' +
  // r'\u1b000-\u1b001' +
  // r'\u1bc00-\u1bc6a' +
  // r'\u1bc70-\u1bc7c' +
  // r'\u1bc80-\u1bc88' +
  // r'\u1bc90-\u1bc99' +
  // r'\u1bc9d-\u1bc9e' +
  // r'\u1d165-\u1d169' +
  // r'\u1d16d-\u1d172' +
  // r'\u1d17b-\u1d182' +
  // r'\u1d185-\u1d18b' +
  // r'\u1d1aa-\u1d1ad' +
  // r'\u1d242-\u1d244' +
  // r'\u1d400-\u1d454' +
  // r'\u1d456-\u1d49c' +
  // r'\u1d49e-\u1d49f' +
  // r'\u1d4a2-\u1d4a2' +
  // r'\u1d4a5-\u1d4a6' +
  // r'\u1d4a9-\u1d4ac' +
  // r'\u1d4ae-\u1d4b9' +
  // r'\u1d4bb-\u1d4bb' +
  // r'\u1d4bd-\u1d4c3' +
  // r'\u1d4c5-\u1d505' +
  // r'\u1d507-\u1d50a' +
  // r'\u1d50d-\u1d514' +
  // r'\u1d516-\u1d51c' +
  // r'\u1d51e-\u1d539' +
  // r'\u1d53b-\u1d53e' +
  // r'\u1d540-\u1d544' +
  // r'\u1d546-\u1d546' +
  // r'\u1d54a-\u1d550' +
  // r'\u1d552-\u1d6a5' +
  // r'\u1d6a8-\u1d6c0' +
  // r'\u1d6c2-\u1d6da' +
  // r'\u1d6dc-\u1d6fa' +
  // r'\u1d6fc-\u1d714' +
  // r'\u1d716-\u1d734' +
  // r'\u1d736-\u1d74e' +
  // r'\u1d750-\u1d76e' +
  // r'\u1d770-\u1d788' +
  // r'\u1d78a-\u1d7a8' +
  // r'\u1d7aa-\u1d7c2' +
  // r'\u1d7c4-\u1d7cb' +
  // r'\u1d7ce-\u1d7ff' +
  // r'\u1da00-\u1da36' +
  // r'\u1da3b-\u1da6c' +
  // r'\u1da75-\u1da75' +
  // r'\u1da84-\u1da84' +
  // r'\u1da9b-\u1da9f' +
  // r'\u1daa1-\u1daaf' +
  // r'\u1e000-\u1e006' +
  // r'\u1e008-\u1e018' +
  // r'\u1e01b-\u1e021' +
  // r'\u1e023-\u1e024' +
  // r'\u1e026-\u1e02a' +
  // r'\u1e800-\u1e8c4' +
  // r'\u1e8d0-\u1e8d6' +
  // r'\u1e900-\u1e94a' +
  // r'\u1e950-\u1e959' +
  // r'\u1ee00-\u1ee03' +
  // r'\u1ee05-\u1ee1f' +
  // r'\u1ee21-\u1ee22' +
  // r'\u1ee24-\u1ee24' +
  // r'\u1ee27-\u1ee27' +
  // r'\u1ee29-\u1ee32' +
  // r'\u1ee34-\u1ee37' +
  // r'\u1ee39-\u1ee39' +
  // r'\u1ee3b-\u1ee3b' +
  // r'\u1ee42-\u1ee42' +
  // r'\u1ee47-\u1ee47' +
  // r'\u1ee49-\u1ee49' +
  // r'\u1ee4b-\u1ee4b' +
  // r'\u1ee4d-\u1ee4f' +
  // r'\u1ee51-\u1ee52' +
  // r'\u1ee54-\u1ee54' +
  // r'\u1ee57-\u1ee57' +
  // r'\u1ee59-\u1ee59' +
  // r'\u1ee5b-\u1ee5b' +
  // r'\u1ee5d-\u1ee5d' +
  // r'\u1ee5f-\u1ee5f' +
  // r'\u1ee61-\u1ee62' +
  // r'\u1ee64-\u1ee64' +
  // r'\u1ee67-\u1ee6a' +
  // r'\u1ee6c-\u1ee72' +
  // r'\u1ee74-\u1ee77' +
  // r'\u1ee79-\u1ee7c' +
  // r'\u1ee7e-\u1ee7e' +
  // r'\u1ee80-\u1ee89' +
  // r'\u1ee8b-\u1ee9b' +
  // r'\u1eea1-\u1eea3' +
  // r'\u1eea5-\u1eea9' +
  // r'\u1eeab-\u1eebb' +
  // r'\u1f130-\u1f149' +
  // r'\u1f150-\u1f169' +
  // r'\u1f170-\u1f189' +
  // r'\u20000-\u2a6d6' +
  // r'\u2a700-\u2b734' +
  // r'\u2b740-\u2b81d' +
  // r'\u2b820-\u2cea1' +
  // r'\u2f800-\u2fa1d' +
  // r'\ue0100-\ue01ef';

  // source: https://github.com/ruby/ruby/blob/ruby_2_4/enc/unicode/9.0.0/name2ctype.h#L4227
const alnum =r'\u0030-\u0039' +
      r'\u0041-\u005a' +
      r'\u0061-\u007a' +
      r'\u00aa-\u00aa' +
      r'\u00b5-\u00b5' +
      r'\u00ba-\u00ba' +
      r'\u00c0-\u00d6' +
      r'\u00d8-\u00f6' +
      r'\u00f8-\u02c1' +
      r'\u02c6-\u02d1' +
      r'\u02e0-\u02e4' +
      r'\u02ec-\u02ec' +
      r'\u02ee-\u02ee' +
      r'\u0345-\u0345' +
      r'\u0370-\u0374' +
      r'\u0376-\u0377' +
      r'\u037a-\u037d' +
      r'\u037f-\u037f' +
      r'\u0386-\u0386' +
      r'\u0388-\u038a' +
      r'\u038c-\u038c' +
      r'\u038e-\u03a1' +
      r'\u03a3-\u03f5' +
      r'\u03f7-\u0481' +
      r'\u048a-\u052f' +
      r'\u0531-\u0556' +
      r'\u0559-\u0559' +
      r'\u0561-\u0587' +
      r'\u05b0-\u05bd' +
      r'\u05bf-\u05bf' +
      r'\u05c1-\u05c2' +
      r'\u05c4-\u05c5' +
      r'\u05c7-\u05c7' +
      r'\u05d0-\u05ea' +
      r'\u05f0-\u05f2' +
      r'\u0610-\u061a' +
      r'\u0620-\u0657' +
      r'\u0659-\u0669' +
      r'\u066e-\u06d3' +
      r'\u06d5-\u06dc' +
      r'\u06e1-\u06e8' +
      r'\u06ed-\u06fc' +
      r'\u06ff-\u06ff' +
      r'\u0710-\u073f' +
      r'\u074d-\u07b1' +
      r'\u07c0-\u07ea' +
      r'\u07f4-\u07f5' +
      r'\u07fa-\u07fa' +
      r'\u0800-\u0817' +
      r'\u081a-\u082c' +
      r'\u0840-\u0858' +
      r'\u08a0-\u08b4' +
      r'\u08b6-\u08bd' +
      r'\u08d4-\u08df' +
      r'\u08e3-\u08e9' +
      r'\u08f0-\u093b' +
      r'\u093d-\u094c' +
      r'\u094e-\u0950' +
      r'\u0955-\u0963' +
      r'\u0966-\u096f' +
      r'\u0971-\u0983' +
      r'\u0985-\u098c' +
      r'\u098f-\u0990' +
      r'\u0993-\u09a8' +
      r'\u09aa-\u09b0' +
      r'\u09b2-\u09b2' +
      r'\u09b6-\u09b9' +
      r'\u09bd-\u09c4' +
      r'\u09c7-\u09c8' +
      r'\u09cb-\u09cc' +
      r'\u09ce-\u09ce' +
      r'\u09d7-\u09d7' +
      r'\u09dc-\u09dd' +
      r'\u09df-\u09e3' +
      r'\u09e6-\u09f1' +
      r'\u0a01-\u0a03' +
      r'\u0a05-\u0a0a' +
      r'\u0a0f-\u0a10' +
      r'\u0a13-\u0a28' +
      r'\u0a2a-\u0a30' +
      r'\u0a32-\u0a33' +
      r'\u0a35-\u0a36' +
      r'\u0a38-\u0a39' +
      r'\u0a3e-\u0a42' +
      r'\u0a47-\u0a48' +
      r'\u0a4b-\u0a4c' +
      r'\u0a51-\u0a51' +
      r'\u0a59-\u0a5c' +
      r'\u0a5e-\u0a5e' +
      r'\u0a66-\u0a75' +
      r'\u0a81-\u0a83' +
      r'\u0a85-\u0a8d' +
      r'\u0a8f-\u0a91' +
      r'\u0a93-\u0aa8' +
      r'\u0aaa-\u0ab0' +
      r'\u0ab2-\u0ab3' +
      r'\u0ab5-\u0ab9' +
      r'\u0abd-\u0ac5' +
      r'\u0ac7-\u0ac9' +
      r'\u0acb-\u0acc' +
      r'\u0ad0-\u0ad0' +
      r'\u0ae0-\u0ae3' +
      r'\u0ae6-\u0aef' +
      r'\u0af9-\u0af9' +
      r'\u0b01-\u0b03' +
      r'\u0b05-\u0b0c' +
      r'\u0b0f-\u0b10' +
      r'\u0b13-\u0b28' +
      r'\u0b2a-\u0b30' +
      r'\u0b32-\u0b33' +
      r'\u0b35-\u0b39' +
      r'\u0b3d-\u0b44' +
      r'\u0b47-\u0b48' +
      r'\u0b4b-\u0b4c' +
      r'\u0b56-\u0b57' +
      r'\u0b5c-\u0b5d' +
      r'\u0b5f-\u0b63' +
      r'\u0b66-\u0b6f' +
      r'\u0b71-\u0b71' +
      r'\u0b82-\u0b83' +
      r'\u0b85-\u0b8a' +
      r'\u0b8e-\u0b90' +
      r'\u0b92-\u0b95' +
      r'\u0b99-\u0b9a' +
      r'\u0b9c-\u0b9c' +
      r'\u0b9e-\u0b9f' +
      r'\u0ba3-\u0ba4' +
      r'\u0ba8-\u0baa' +
      r'\u0bae-\u0bb9' +
      r'\u0bbe-\u0bc2' +
      r'\u0bc6-\u0bc8' +
      r'\u0bca-\u0bcc' +
      r'\u0bd0-\u0bd0' +
      r'\u0bd7-\u0bd7' +
      r'\u0be6-\u0bef' +
      r'\u0c00-\u0c03' +
      r'\u0c05-\u0c0c' +
      r'\u0c0e-\u0c10' +
      r'\u0c12-\u0c28' +
      r'\u0c2a-\u0c39' +
      r'\u0c3d-\u0c44' +
      r'\u0c46-\u0c48' +
      r'\u0c4a-\u0c4c' +
      r'\u0c55-\u0c56' +
      r'\u0c58-\u0c5a' +
      r'\u0c60-\u0c63' +
      r'\u0c66-\u0c6f' +
      r'\u0c80-\u0c83' +
      r'\u0c85-\u0c8c' +
      r'\u0c8e-\u0c90' +
      r'\u0c92-\u0ca8' +
      r'\u0caa-\u0cb3' +
      r'\u0cb5-\u0cb9' +
      r'\u0cbd-\u0cc4' +
      r'\u0cc6-\u0cc8' +
      r'\u0cca-\u0ccc' +
      r'\u0cd5-\u0cd6' +
      r'\u0cde-\u0cde' +
      r'\u0ce0-\u0ce3' +
      r'\u0ce6-\u0cef' +
      r'\u0cf1-\u0cf2' +
      r'\u0d01-\u0d03' +
      r'\u0d05-\u0d0c' +
      r'\u0d0e-\u0d10' +
      r'\u0d12-\u0d3a' +
      r'\u0d3d-\u0d44' +
      r'\u0d46-\u0d48' +
      r'\u0d4a-\u0d4c' +
      r'\u0d4e-\u0d4e' +
      r'\u0d54-\u0d57' +
      r'\u0d5f-\u0d63' +
      r'\u0d66-\u0d6f' +
      r'\u0d7a-\u0d7f' +
      r'\u0d82-\u0d83' +
      r'\u0d85-\u0d96' +
      r'\u0d9a-\u0db1' +
      r'\u0db3-\u0dbb' +
      r'\u0dbd-\u0dbd' +
      r'\u0dc0-\u0dc6' +
      r'\u0dcf-\u0dd4' +
      r'\u0dd6-\u0dd6' +
      r'\u0dd8-\u0ddf' +
      r'\u0de6-\u0def' +
      r'\u0df2-\u0df3' +
      r'\u0e01-\u0e3a' +
      r'\u0e40-\u0e46' +
      r'\u0e4d-\u0e4d' +
      r'\u0e50-\u0e59' +
      r'\u0e81-\u0e82' +
      r'\u0e84-\u0e84' +
      r'\u0e87-\u0e88' +
      r'\u0e8a-\u0e8a' +
      r'\u0e8d-\u0e8d' +
      r'\u0e94-\u0e97' +
      r'\u0e99-\u0e9f' +
      r'\u0ea1-\u0ea3' +
      r'\u0ea5-\u0ea5' +
      r'\u0ea7-\u0ea7' +
      r'\u0eaa-\u0eab' +
      r'\u0ead-\u0eb9' +
      r'\u0ebb-\u0ebd' +
      r'\u0ec0-\u0ec4' +
      r'\u0ec6-\u0ec6' +
      r'\u0ecd-\u0ecd' +
      r'\u0ed0-\u0ed9' +
      r'\u0edc-\u0edf' +
      r'\u0f00-\u0f00' +
      r'\u0f20-\u0f29' +
      r'\u0f40-\u0f47' +
      r'\u0f49-\u0f6c' +
      r'\u0f71-\u0f81' +
      r'\u0f88-\u0f97' +
      r'\u0f99-\u0fbc' +
      r'\u1000-\u1036' +
      r'\u1038-\u1038' +
      r'\u103b-\u1049' +
      r'\u1050-\u1062' +
      r'\u1065-\u1068' +
      r'\u106e-\u1086' +
      r'\u108e-\u108e' +
      r'\u1090-\u1099' +
      r'\u109c-\u109d' +
      r'\u10a0-\u10c5' +
      r'\u10c7-\u10c7' +
      r'\u10cd-\u10cd' +
      r'\u10d0-\u10fa' +
      r'\u10fc-\u1248' +
      r'\u124a-\u124d' +
      r'\u1250-\u1256' +
      r'\u1258-\u1258' +
      r'\u125a-\u125d' +
      r'\u1260-\u1288' +
      r'\u128a-\u128d' +
      r'\u1290-\u12b0' +
      r'\u12b2-\u12b5' +
      r'\u12b8-\u12be' +
      r'\u12c0-\u12c0' +
      r'\u12c2-\u12c5' +
      r'\u12c8-\u12d6' +
      r'\u12d8-\u1310' +
      r'\u1312-\u1315' +
      r'\u1318-\u135a' +
      r'\u135f-\u135f' +
      r'\u1380-\u138f' +
      r'\u13a0-\u13f5' +
      r'\u13f8-\u13fd' +
      r'\u1401-\u166c' +
      r'\u166f-\u167f' +
      r'\u1681-\u169a' +
      r'\u16a0-\u16ea' +
      r'\u16ee-\u16f8' +
      r'\u1700-\u170c' +
      r'\u170e-\u1713' +
      r'\u1720-\u1733' +
      r'\u1740-\u1753' +
      r'\u1760-\u176c' +
      r'\u176e-\u1770' +
      r'\u1772-\u1773' +
      r'\u1780-\u17b3' +
      r'\u17b6-\u17c8' +
      r'\u17d7-\u17d7' +
      r'\u17dc-\u17dc' +
      r'\u17e0-\u17e9' +
      r'\u1810-\u1819' +
      r'\u1820-\u1877' +
      r'\u1880-\u18aa' +
      r'\u18b0-\u18f5' +
      r'\u1900-\u191e' +
      r'\u1920-\u192b' +
      r'\u1930-\u1938' +
      r'\u1946-\u196d' +
      r'\u1970-\u1974' +
      r'\u1980-\u19ab' +
      r'\u19b0-\u19c9' +
      r'\u19d0-\u19d9' +
      r'\u1a00-\u1a1b' +
      r'\u1a20-\u1a5e' +
      r'\u1a61-\u1a74' +
      r'\u1a80-\u1a89' +
      r'\u1a90-\u1a99' +
      r'\u1aa7-\u1aa7' +
      r'\u1b00-\u1b33' +
      r'\u1b35-\u1b43' +
      r'\u1b45-\u1b4b' +
      r'\u1b50-\u1b59' +
      r'\u1b80-\u1ba9' +
      r'\u1bac-\u1be5' +
      r'\u1be7-\u1bf1' +
      r'\u1c00-\u1c35' +
      r'\u1c40-\u1c49' +
      r'\u1c4d-\u1c7d' +
      r'\u1c80-\u1c88' +
      r'\u1ce9-\u1cec' +
      r'\u1cee-\u1cf3' +
      r'\u1cf5-\u1cf6' +
      r'\u1d00-\u1dbf' +
      r'\u1de7-\u1df4' +
      r'\u1e00-\u1f15' +
      r'\u1f18-\u1f1d' +
      r'\u1f20-\u1f45' +
      r'\u1f48-\u1f4d' +
      r'\u1f50-\u1f57' +
      r'\u1f59-\u1f59' +
      r'\u1f5b-\u1f5b' +
      r'\u1f5d-\u1f5d' +
      r'\u1f5f-\u1f7d' +
      r'\u1f80-\u1fb4' +
      r'\u1fb6-\u1fbc' +
      r'\u1fbe-\u1fbe' +
      r'\u1fc2-\u1fc4' +
      r'\u1fc6-\u1fcc' +
      r'\u1fd0-\u1fd3' +
      r'\u1fd6-\u1fdb' +
      r'\u1fe0-\u1fec' +
      r'\u1ff2-\u1ff4' +
      r'\u1ff6-\u1ffc' +
      r'\u2071-\u2071' +
      r'\u207f-\u207f' +
      r'\u2090-\u209c' +
      r'\u2102-\u2102' +
      r'\u2107-\u2107' +
      r'\u210a-\u2113' +
      r'\u2115-\u2115' +
      r'\u2119-\u211d' +
      r'\u2124-\u2124' +
      r'\u2126-\u2126' +
      r'\u2128-\u2128' +
      r'\u212a-\u212d' +
      r'\u212f-\u2139' +
      r'\u213c-\u213f' +
      r'\u2145-\u2149' +
      r'\u214e-\u214e' +
      r'\u2160-\u2188' +
      r'\u24b6-\u24e9' +
      r'\u2c00-\u2c2e' +
      r'\u2c30-\u2c5e' +
      r'\u2c60-\u2ce4' +
      r'\u2ceb-\u2cee' +
      r'\u2cf2-\u2cf3' +
      r'\u2d00-\u2d25' +
      r'\u2d27-\u2d27' +
      r'\u2d2d-\u2d2d' +
      r'\u2d30-\u2d67' +
      r'\u2d6f-\u2d6f' +
      r'\u2d80-\u2d96' +
      r'\u2da0-\u2da6' +
      r'\u2da8-\u2dae' +
      r'\u2db0-\u2db6' +
      r'\u2db8-\u2dbe' +
      r'\u2dc0-\u2dc6' +
      r'\u2dc8-\u2dce' +
      r'\u2dd0-\u2dd6' +
      r'\u2dd8-\u2dde' +
      r'\u2de0-\u2dff' +
      r'\u2e2f-\u2e2f' +
      r'\u3005-\u3007' +
      r'\u3021-\u3029' +
      r'\u3031-\u3035' +
      r'\u3038-\u303c' +
      r'\u3041-\u3096' +
      r'\u309d-\u309f' +
      r'\u30a1-\u30fa' +
      r'\u30fc-\u30ff' +
      r'\u3105-\u312d' +
      r'\u3131-\u318e' +
      r'\u31a0-\u31ba' +
      r'\u31f0-\u31ff' +
      r'\u3400-\u4db5' +
      r'\u4e00-\u9fd5' +
      r'\ua000-\ua48c' +
      r'\ua4d0-\ua4fd' +
      r'\ua500-\ua60c' +
      r'\ua610-\ua62b' +
      r'\ua640-\ua66e' +
      r'\ua674-\ua67b' +
      r'\ua67f-\ua6ef' +
      r'\ua717-\ua71f' +
      r'\ua722-\ua788' +
      r'\ua78b-\ua7ae' +
      r'\ua7b0-\ua7b7' +
      r'\ua7f7-\ua801' +
      r'\ua803-\ua805' +
      r'\ua807-\ua80a' +
      r'\ua80c-\ua827' +
      r'\ua840-\ua873' +
      r'\ua880-\ua8c3' +
      r'\ua8c5-\ua8c5' +
      r'\ua8d0-\ua8d9' +
      r'\ua8f2-\ua8f7' +
      r'\ua8fb-\ua8fb' +
      r'\ua8fd-\ua8fd' +
      r'\ua900-\ua92a' +
      r'\ua930-\ua952' +
      r'\ua960-\ua97c' +
      r'\ua980-\ua9b2' +
      r'\ua9b4-\ua9bf' +
      r'\ua9cf-\ua9d9' +
      r'\ua9e0-\ua9e4' +
      r'\ua9e6-\ua9fe' +
      r'\uaa00-\uaa36' +
      r'\uaa40-\uaa4d' +
      r'\uaa50-\uaa59' +
      r'\uaa60-\uaa76' +
      r'\uaa7a-\uaa7a' +
      r'\uaa7e-\uaabe' +
      r'\uaac0-\uaac0' +
      r'\uaac2-\uaac2' +
      r'\uaadb-\uaadd' +
      r'\uaae0-\uaaef' +
      r'\uaaf2-\uaaf5' +
      r'\uab01-\uab06' +
      r'\uab09-\uab0e' +
      r'\uab11-\uab16' +
      r'\uab20-\uab26' +
      r'\uab28-\uab2e' +
      r'\uab30-\uab5a' +
      r'\uab5c-\uab65' +
      r'\uab70-\uabea' +
      r'\uabf0-\uabf9' +
      r'\uac00-\ud7a3' +
      r'\ud7b0-\ud7c6' +
      r'\ud7cb-\ud7fb' +
      r'\uf900-\ufa6d' +
      r'\ufa70-\ufad9' +
      r'\ufb00-\ufb06' +
      r'\ufb13-\ufb17' +
      r'\ufb1d-\ufb28' +
      r'\ufb2a-\ufb36' +
      r'\ufb38-\ufb3c' +
      r'\ufb3e-\ufb3e' +
      r'\ufb40-\ufb41' +
      r'\ufb43-\ufb44' +
      r'\ufb46-\ufbb1' +
      r'\ufbd3-\ufd3d' +
      r'\ufd50-\ufd8f' +
      r'\ufd92-\ufdc7' +
      r'\ufdf0-\ufdfb' +
      r'\ufe70-\ufe74' +
      r'\ufe76-\ufefc' +
      r'\uff10-\uff19' +
      r'\uff21-\uff3a' +
      r'\uff41-\uff5a' +
      r'\uff66-\uffbe' +
      r'\uffc2-\uffc7' +
      r'\uffca-\uffcf' +
      r'\uffd2-\uffd7' +
      r'\uffda-\uffdc';
  // r'\u10000-\u1000b' +
  // r'\u1000d-\u10026' +
  // r'\u10028-\u1003a' +
  // r'\u1003c-\u1003d' +
  // r'\u1003f-\u1004d' +
  // r'\u10050-\u1005d' +
  // r'\u10080-\u100fa' +
  // r'\u10140-\u10174' +
  // r'\u10280-\u1029c' +
  // r'\u102a0-\u102d0' +
  // r'\u10300-\u1031f' +
  // r'\u10330-\u1034a' +
  // r'\u10350-\u1037a' +
  // r'\u10380-\u1039d' +
  // r'\u103a0-\u103c3' +
  // r'\u103c8-\u103cf' +
  // r'\u103d1-\u103d5' +
  // r'\u10400-\u1049d' +
  // r'\u104a0-\u104a9' +
  // r'\u104b0-\u104d3' +
  // r'\u104d8-\u104fb' +
  // r'\u10500-\u10527' +
  // r'\u10530-\u10563' +
  // r'\u10600-\u10736' +
  // r'\u10740-\u10755' +
  // r'\u10760-\u10767' +
  // r'\u10800-\u10805' +
  // r'\u10808-\u10808' +
  // r'\u1080a-\u10835' +
  // r'\u10837-\u10838' +
  // r'\u1083c-\u1083c' +
  // r'\u1083f-\u10855' +
  // r'\u10860-\u10876' +
  // r'\u10880-\u1089e' +
  // r'\u108e0-\u108f2' +
  // r'\u108f4-\u108f5' +
  // r'\u10900-\u10915' +
  // r'\u10920-\u10939' +
  // r'\u10980-\u109b7' +
  // r'\u109be-\u109bf' +
  // r'\u10a00-\u10a03' +
  // r'\u10a05-\u10a06' +
  // r'\u10a0c-\u10a13' +
  // r'\u10a15-\u10a17' +
  // r'\u10a19-\u10a33' +
  // r'\u10a60-\u10a7c' +
  // r'\u10a80-\u10a9c' +
  // r'\u10ac0-\u10ac7' +
  // r'\u10ac9-\u10ae4' +
  // r'\u10b00-\u10b35' +
  // r'\u10b40-\u10b55' +
  // r'\u10b60-\u10b72' +
  // r'\u10b80-\u10b91' +
  // r'\u10c00-\u10c48' +
  // r'\u10c80-\u10cb2' +
  // r'\u10cc0-\u10cf2' +
  // r'\u11000-\u11045' +
  // r'\u11066-\u1106f' +
  // r'\u11082-\u110b8' +
  // r'\u110d0-\u110e8' +
  // r'\u110f0-\u110f9' +
  // r'\u11100-\u11132' +
  // r'\u11136-\u1113f' +
  // r'\u11150-\u11172' +
  // r'\u11176-\u11176' +
  // r'\u11180-\u111bf' +
  // r'\u111c1-\u111c4' +
  // r'\u111d0-\u111da' +
  // r'\u111dc-\u111dc' +
  // r'\u11200-\u11211' +
  // r'\u11213-\u11234' +
  // r'\u11237-\u11237' +
  // r'\u1123e-\u1123e' +
  // r'\u11280-\u11286' +
  // r'\u11288-\u11288' +
  // r'\u1128a-\u1128d' +
  // r'\u1128f-\u1129d' +
  // r'\u1129f-\u112a8' +
  // r'\u112b0-\u112e8' +
  // r'\u112f0-\u112f9' +
  // r'\u11300-\u11303' +
  // r'\u11305-\u1130c' +
  // r'\u1130f-\u11310' +
  // r'\u11313-\u11328' +
  // r'\u1132a-\u11330' +
  // r'\u11332-\u11333' +
  // r'\u11335-\u11339' +
  // r'\u1133d-\u11344' +
  // r'\u11347-\u11348' +
  // r'\u1134b-\u1134c' +
  // r'\u11350-\u11350' +
  // r'\u11357-\u11357' +
  // r'\u1135d-\u11363' +
  // r'\u11400-\u11441' +
  // r'\u11443-\u11445' +
  // r'\u11447-\u1144a' +
  // r'\u11450-\u11459' +
  // r'\u11480-\u114c1' +
  // r'\u114c4-\u114c5' +
  // r'\u114c7-\u114c7' +
  // r'\u114d0-\u114d9' +
  // r'\u11580-\u115b5' +
  // r'\u115b8-\u115be' +
  // r'\u115d8-\u115dd' +
  // r'\u11600-\u1163e' +
  // r'\u11640-\u11640' +
  // r'\u11644-\u11644' +
  // r'\u11650-\u11659' +
  // r'\u11680-\u116b5' +
  // r'\u116c0-\u116c9' +
  // r'\u11700-\u11719' +
  // r'\u1171d-\u1172a' +
  // r'\u11730-\u11739' +
  // r'\u118a0-\u118e9' +
  // r'\u118ff-\u118ff' +
  // r'\u11ac0-\u11af8' +
  // r'\u11c00-\u11c08' +
  // r'\u11c0a-\u11c36' +
  // r'\u11c38-\u11c3e' +
  // r'\u11c40-\u11c40' +
  // r'\u11c50-\u11c59' +
  // r'\u11c72-\u11c8f' +
  // r'\u11c92-\u11ca7' +
  // r'\u11ca9-\u11cb6' +
  // r'\u12000-\u12399' +
  // r'\u12400-\u1246e' +
  // r'\u12480-\u12543' +
  // r'\u13000-\u1342e' +
  // r'\u14400-\u14646' +
  // r'\u16800-\u16a38' +
  // r'\u16a40-\u16a5e' +
  // r'\u16a60-\u16a69' +
  // r'\u16ad0-\u16aed' +
  // r'\u16b00-\u16b36' +
  // r'\u16b40-\u16b43' +
  // r'\u16b50-\u16b59' +
  // r'\u16b63-\u16b77' +
  // r'\u16b7d-\u16b8f' +
  // r'\u16f00-\u16f44' +
  // r'\u16f50-\u16f7e' +
  // r'\u16f93-\u16f9f' +
  // r'\u16fe0-\u16fe0' +
  // r'\u17000-\u187ec' +
  // r'\u18800-\u18af2' +
  // r'\u1b000-\u1b001' +
  // r'\u1bc00-\u1bc6a' +
  // r'\u1bc70-\u1bc7c' +
  // r'\u1bc80-\u1bc88' +
  // r'\u1bc90-\u1bc99' +
  // r'\u1bc9e-\u1bc9e' +
  // r'\u1d400-\u1d454' +
  // r'\u1d456-\u1d49c' +
  // r'\u1d49e-\u1d49f' +
  // r'\u1d4a2-\u1d4a2' +
  // r'\u1d4a5-\u1d4a6' +
  // r'\u1d4a9-\u1d4ac' +
  // r'\u1d4ae-\u1d4b9' +
  // r'\u1d4bb-\u1d4bb' +
  // r'\u1d4bd-\u1d4c3' +
  // r'\u1d4c5-\u1d505' +
  // r'\u1d507-\u1d50a' +
  // r'\u1d50d-\u1d514' +
  // r'\u1d516-\u1d51c' +
  // r'\u1d51e-\u1d539' +
  // r'\u1d53b-\u1d53e' +
  // r'\u1d540-\u1d544' +
  // r'\u1d546-\u1d546' +
  // r'\u1d54a-\u1d550' +
  // r'\u1d552-\u1d6a5' +
  // r'\u1d6a8-\u1d6c0' +
  // r'\u1d6c2-\u1d6da' +
  // r'\u1d6dc-\u1d6fa' +
  // r'\u1d6fc-\u1d714' +
  // r'\u1d716-\u1d734' +
  // r'\u1d736-\u1d74e' +
  // r'\u1d750-\u1d76e' +
  // r'\u1d770-\u1d788' +
  // r'\u1d78a-\u1d7a8' +
  // r'\u1d7aa-\u1d7c2' +
  // r'\u1d7c4-\u1d7cb' +
  // r'\u1d7ce-\u1d7ff' +
  // r'\u1e000-\u1e006' +
  // r'\u1e008-\u1e018' +
  // r'\u1e01b-\u1e021' +
  // r'\u1e023-\u1e024' +
  // r'\u1e026-\u1e02a' +
  // r'\u1e800-\u1e8c4' +
  // r'\u1e900-\u1e943' +
  // r'\u1e947-\u1e947' +
  // r'\u1e950-\u1e959' +
  // r'\u1ee00-\u1ee03' +
  // r'\u1ee05-\u1ee1f' +
  // r'\u1ee21-\u1ee22' +
  // r'\u1ee24-\u1ee24' +
  // r'\u1ee27-\u1ee27' +
  // r'\u1ee29-\u1ee32' +
  // r'\u1ee34-\u1ee37' +
  // r'\u1ee39-\u1ee39' +
  // r'\u1ee3b-\u1ee3b' +
  // r'\u1ee42-\u1ee42' +
  // r'\u1ee47-\u1ee47' +
  // r'\u1ee49-\u1ee49' +
  // r'\u1ee4b-\u1ee4b' +
  // r'\u1ee4d-\u1ee4f' +
  // r'\u1ee51-\u1ee52' +
  // r'\u1ee54-\u1ee54' +
  // r'\u1ee57-\u1ee57' +
  // r'\u1ee59-\u1ee59' +
  // r'\u1ee5b-\u1ee5b' +
  // r'\u1ee5d-\u1ee5d' +
  // r'\u1ee5f-\u1ee5f' +
  // r'\u1ee61-\u1ee62' +
  // r'\u1ee64-\u1ee64' +
  // r'\u1ee67-\u1ee6a' +
  // r'\u1ee6c-\u1ee72' +
  // r'\u1ee74-\u1ee77' +
  // r'\u1ee79-\u1ee7c' +
  // r'\u1ee7e-\u1ee7e' +
  // r'\u1ee80-\u1ee89' +
  // r'\u1ee8b-\u1ee9b' +
  // r'\u1eea1-\u1eea3' +
  // r'\u1eea5-\u1eea9' +
  // r'\u1eeab-\u1eebb' +
  // r'\u1f130-\u1f149' +
  // r'\u1f150-\u1f169' +
  // r'\u1f170-\u1f189' +
  // r'\u20000-\u2a6d6' +
  // r'\u2a700-\u2b734' +
  // r'\u2b740-\u2b81d' +
  // r'\u2b820-\u2cea1' +
  // r'\u2f800-\u2fa1d';
