abstract class AppInfo {
  static const String name = '{{titleCaseProjectName}}';
  static const String packageName = '{{projectName}}';
  static const String version = '1.0.0';
  static const String author = 'Hossein';

  static const String githubHandle = 'psdkjoon';
  static const String repoName = '{{projectName}}';
  static const String githubUrl = 'https://github.com/$githubHandle';
  static const String githubDisplay = 'github.com/$githubHandle';
  static const String repoUrl = '$githubUrl/$repoName';
  static const String repoDisplay = 'github.com/$githubHandle/$repoName';

  static const String telegramHandle = 'psdkjoon';
  static const String telegramUrl = 'https://t.me/$telegramHandle';
  static const String telegramDisplay = '@$telegramHandle';

  // Donations from Iran go through Daramet, which accepts Iranian payments.
  static const String donateIranUrl = 'https://daramet.com/psdkjoon';
  static const String donateIranDisplay = 'daramet.com/psdkjoon';

  // Donations from everywhere else go straight to these wallets (shown in the
  // donate sheet). Each address is only valid on the network written next to it.
  // The network text is a translation key, see strings_*.dart.
  static const List<CryptoWallet> wallets = <CryptoWallet>[
    CryptoWallet(
      coin: 'Bitcoin',
      asset: 'assets/icons/coins/btc.svg',
      network: 'Bitcoin network',
      address: 'bc1q2p72az3e09zmq7nj3pydamv3rcav070c7yck0h',
    ),
    CryptoWallet(
      coin: 'USDT',
      asset: 'assets/icons/coins/usdt.svg',
      network: 'TRON network (TRC-20)',
      address: 'TSemVbsVbZw6MeAUSfBBLPAadxSw18RYHd',
    ),
    CryptoWallet(
      coin: 'USDC',
      asset: 'assets/icons/coins/usdc.svg',
      network: 'Base network',
      address: '0x3692C9Dc9e8984D6399C74B2454d1Cf5A90bD1E4',
    ),
  ];

  static const String linuxPackageName = '{{linuxIdentifier}}';

  static const bool usesNotifications = false;

  /// Set to true when the app must keep working with the screen off: a
  /// foreground service, scheduled work, reminders or alarms. The app then asks
  /// for notifications (the service notification needs it) and for exemption
  /// from battery optimization when it starts. The manifest already declares
  /// FOREGROUND_SERVICE, WAKE_LOCK, RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM
  /// and REQUEST_IGNORE_BATTERY_OPTIMIZATIONS.
  static const bool usesBackground = false;
}

class CryptoWallet {
  const CryptoWallet({
    required this.coin,
    required this.asset,
    required this.network,
    required this.address,
  });

  final String coin;

  /// A single-color SVG of the coin's mark, tinted with the theme accent.
  final String asset;

  final String network;
  final String address;
}
