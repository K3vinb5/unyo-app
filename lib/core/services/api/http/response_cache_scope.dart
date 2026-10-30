/// Scope token for cached API responses.
///
/// A metadata-provider switch must never serve rows fetched under the previous
/// provider. The screens' cubits hear about the switch through
/// `ReloadType.newMetadataService`, but a lazy tab (`AutoTabsRouter
/// lazyLoad: true`) has no cubit yet to receive that broadcast: its first load
/// happens after the switch and asks for `ignoreCache: false`, so without a
/// scope it would be handed the previous provider's cached payload.
///
/// `HttpService` tags every cached response with [revision], so bumping it
/// ([invalidate]) makes every entry cached under the previous provider
/// unreachable — provider-agnostically, and without every call site having to
/// know a switch happened.
class ResponseCacheScope {
  int _revision = 0;

  int get revision => _revision;

  void invalidate() => _revision++;
}
