class Enum {
  static Map<String, String> dataFields = {
    'CM': '1',
    'COMMENT': '2',
    'PICTURE': '3',
    'LINK': '4',
    'UPLOAD': '5',
    'STAMP': '6',
  };
}

enum FORM_TYPE { DIVE, SAMPLE, ANALYSIS }

enum DELETE_TYPE {
  EXPEDITION,
  PLATFORM,
  TOOL,
  DATA,
  AREA,
  DIVE,
  SAMPLE,
  ANALYSIS,
  LOCATION
}

enum PictureFolderName { sample, tool, platform, dive, analysis, record }
