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
// REST surface. The calendar exists **only** over REST (`/api/calendar`); the
// `/api/v1/calendar` path is a 404 page (WP #64 evidence
// `raws/api/rest-v1-calendar-404.html`). GraphQL has no calendar root field.
const String shikimoriRestEndpoint = 'https://shikimori.io/api';
const String shikimoriCalendarEndpoint = '$shikimoriRestEndpoint/calendar';
/// Relative poster paths (`/system/animes/original/1.jpg?…`) are served from
/// the site root, not from `/api`.
const String shikimoriSiteEndpoint = 'https://shikimori.io';
// Shikimori bans IPs that call its API without a meaningful User-Agent
// (shikimori.io/api/doc, "Restrictions"/"Requirements"), so every request —
// GraphQL today, REST once the calendar/user_rates work lands — carries this
// one header map instead of one literal per call site.
const Map<String, String> shikimoriRequestHeaders = <String, String>{
  'User-Agent': 'unyo (https://gitea.k3vinb5.dev/Unyo/unyo-app)',
};
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