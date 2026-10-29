// Application configuration
// Update check configuration
const String unyoReleasesEndpoint = 'https://api.github.com/repos/K3vinb5/Unyo/releases/latest';
const String unyoReleasesFallbackUrl = 'https://github.com/K3vinb5/Unyo/releases/latest';
// Locator configuration
const String applicationSupportDirectory = "applicationSupportDirectory";
const String loggedUserNotifier = 'loggedUserNotifier';
const String newUserNotifier = 'newUserNotifier';
// Anilist API configuration
const String anilistOAuthEndpoint = 'https://anilist.co/api/v2/oauth/token';
const String anilistAuthUrl =
    'https://anilist.co/api/v2/oauth/authorize?client_id=$anilistClientId&redirect_uri=$anilistRedirectUri&response_type=code';
const String anilistRedirectUri = 'http://localhost:9999/auth';
const String anilistClientId = '17550';
const String anilistClientSecret = 'xI8KTZlKm2F3kHXLko1ArQ21bKap4MojgDTk6Ukx';
const String anilistGraphQlService = 'anilistGraphQlService';
const String anilistGraphQLEndpoint = 'https://graphql.anilist.co';
// Shikimori API configuration
const String shikimoriOAuthUrl ='https://shikimori.io/oauth/authorize?client_id=$shikimoriClientId&redirect_uri=$shikimoriRedirectUri&response_type=code&scope=user_rates';
const String shikimoriRedirectUri = 'http://localhost:9999/auth';
const String shikimoriClientId = 'sIjHVKp4D3gusN53hob4tDnmvFYgySDiLpWJNTsfVcA';
const String shikimoriClientSecret = '6y39AFgZ8Ww6cESH_BzyZqYjZRSCrTy9meoY1nm2Cj0';
const String shikimoriGraphQlService = 'shikimoriGraphQlService';
const String shikimoriGraphQLEndpoint = 'https://shikimori.io/api/graphql';
// Anizip API configuration
const String anizipBaseEndpoint = 'https://api.ani.zip';
// Aniski API configuration
const String aniskiBaseEndpoint = 'https://api.aniskip.com';
// Torrent API configuration
const String torrentServiceEndpoint = 'http://127.0.0.1:8090';
// Cache configuration
const String localhost = '127.0.0.1';
const Set<String> cacheDisabledEndpoints = <String>{
  anilistOAuthEndpoint,
};
const Set<String> cacheDisabledHosts = <String>{
  localhost,
};
const Set<String> cacheIgnoredHeaders = <String>{
  'Authorization'
};
// Extensions condiguration
const String aniyomiExtensionsDefaultRepositoryUrl = 'https://gitea.k3vinb5.dev/Backups/kohi-den-extensions/raw/branch/main/index.min.json';
const String tachiyomiExtensionsDefaultRepositoryUrl = 'https://gitea.k3vinb5.dev/Backups/keiyoushi-extensions/raw/branch/repo/index.min.json';
// TODO move to an asset
const plusImageUrl = "https://i.ibb.co/Kj8CQZH/cross.png";