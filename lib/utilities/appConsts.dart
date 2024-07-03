class AppConsts {
  static const baseURL = "http://54.77.85.64:8529/_db/adepth/";

  static const signin = "auth/signin";
  static const login = "auth/login";

  static const saveExpedition = "project/post/expedition";
  static const expeditionsList = "project/get/expeditionsList";
  static const expeditionDocument = "project/get/expedition/";

  static const saveArea = "project/post/area";
  static const areaList = "project/get/areaList/";
  static const areaDocument = "project/get/area/";

  static const savePlatform = "project/post/platform";
  static const platformList = "project/get/platformList/";
  static const platformDocument = "project/get/platform/";

  static const saveData = "project/post/data";
  static const dataList =
      "project/get/dataList/"; // return complete list to display
  static const dataDocument = "project/get/data/";

  static const saveTool = "project/post/tool";
  static const toolList = "project/get/toolList/";
  static const toolDocument = "project/get/tool/";

  static const saveLocation = "project/post/location";
  static const locationList = "project/get/locationList/";
  static const locationDocument = "project/get/location/";

  static const saveDive = "project/post/dive";
  static const diveList = "project/get/diveList/";
  static const diveDocument = "project/get/dive/";

  static const saveSample = "project/post/sample";
  static const sampleList = "project/get/sampleList/";
  static const sampleDocument = "project/get/sample/";

  static const sampleListOngoingLocation =
      "project/get/sampleListOngoingLocation/";
  static const diveListOngoingLocation = "project/get/diveListOngoingLocation/";

  static const saveAnalysis = "project/post/analysis";
  static const analysisList = "project/get/analysisList/";
  static const analysisDocument = "project/get/analysis/";

  static const saveRecord = "project/post/record";
  static const recordDocument = "project/get/record/";

  static const platformAndAreaList = "api/get/platformAndAreaList/";
  static const dataMetaData = "api/get/dataMetaData";
  static const dataListMetaData =
      "api/get/dataList/"; // return dropdown meta data name, key
  static const dataRecordList =
      "api/get/dataRecordList/"; // return dropdown meta data name, key
  static const sampleMetaData = "api/get/sampleMetaData/";
  static const softDelete = "api/utils/softDelete";
  static const deleteArea = "api/utils/deleteArea";
  static const deleteLocation = "api/utils/deleteLocation";
  static const deleteDive = "api/utils/deleteDive";
  static const deleteSample = "api/utils/deleteSample";
  static const updateDocument = "api/utils/updateDocument";
  static const generateReport = "api/utils/generateReport/";

  static const generateNameArea = "api/generateName/area/";
  static const generateNameLocation = "api/generateName/location/";
  static const generateNameDive = "api/generateName/dive/";
  static const generateNameSample = "api/generateName/sample/";
  static const generateNameAnalysis = "api/generateName/analysis/";
  static const generateNameRecord = "api/generateName/record/";
}
