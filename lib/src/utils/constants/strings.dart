// App
const String appTitle = 'Bex Deliveries';

// Log header:
const String headerMainLogger = 'main';
const String headerLoginLogger = 'login';
const String headerHomeLogger = 'home';
const String headerWorkLogger = 'work';
const String headerSummaryLogger = 'summary';
const String headerNavigationLogger = 'navigation';
const String headerDrawerLogger = 'drawer';
const String headerIssueLogger = 'issue';
const String headerCollectionLogger = 'issue';
const String headerDeveloperLogger = 'developer';

//routes
class AppRoutes {
  //AUTH ROUTES
  static const splash = '/splash';
  static const politics = '/politics';
  static const company = '/company';
  static const permission = '/permission';
  static const login = '/login';
  //HOME ROUTES
  static  const home = '/home';
  //WORK ROUTES
  static const work = '/work';
  static const confirm = '/confirm-work';
  static const history = '/historic';
  static const navigation = '/navigation';
  //SUMMARY ROUTES
  static const summary = '/summary';
  static const summaryNavigation = '/summary-navigation';
  static const summaryGeoReference = '/summary-geo-reference';

  static const inventory = '/inventory';
  static const package = '/package';
  static const camera = '/camera';
  static const firm = '/firm';
  static const qr = '/code-qr';
  static const photo = '/photos';
  static const detailPhoto = '/detail-photo';
  //TRANSACTIONS ROUTES
  static const collection = '/collection';
  static const partial = '/partial';
  static const reject = '/reject';
  static const respawn = '/respawn';
  //DRAWER ROUTES
  static const notifications = '/notifications';
  static const transaction = '/transaction';
  static const query = '/query';
  static const dispatch = '/dispatch';
  static const quote = '/quote';
  static const collectionQuery = '/collection-query';
  static const devolutionQuery = '/devolution-query';
  static const respawnQuery = '/respawn-query';
  //DEVELOPER ROUTES
  static const database = '/database';
  static const processingQueue = '/processing-queue';
  static const transactions = '/transactions';
  static const locations = '/locations';
  static const issue = '/issues';
  static const fillIssue = '/fill-issue';
  static const codeQr = '/code-qr';
}


const String buttonTextDefault = "Permitir";
const String buttonTextSuccess = "Continuar";
const String buttonTextPermanentlyDenied = "Configuración";
const String titleDefault = "Permiso necesario";
const String displayMessageDefault =
    "Para brindarle la mejor experiencia de usuario, necesitamos algunos permisos. Por favor permítelo.";
const String displayMessageSuccess =
    "Éxito, se otorgaron todos los permisos. Por favor, haga clic en el botón de abajo para continuar.";
const String displayMessageDenied =
    "Para brindarle la mejor experiencia de usuario, necesitamos algunos permisos, pero parece que lo negó.";
const String displayMessagePermanentlyDenied =
    "Para brindarle la mejor experiencia de usuario, necesitamos algunos permisos, pero parece que lo denegó permanentemente. Vaya a la configuración y actívela manualmente para continuar.";
