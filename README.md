<p align="center">
    <img width="120px" src="./assets/logo.png"/>
    <h1 align="center">Unyo</h1>
</p>

<p align="center">A simple desktop app for streaming anime and reading manga.</p>

<p align="center">
<a href="https://img.shields.io/github/license/K3vinb5/Unyo?style=for-the-badge"><img src="https://img.shields.io/github/license/K3vinb5/Unyo?style=for-the-badge&color=F48041"></a>
<a href="https://img.shields.io/github/v/release/K3vinb5/Unyo?style=for-the-badge"><img src="https://img.shields.io/github/v/release/K3vinb5/Unyo?style=for-the-badge&color=0E80C0"></a>
<a href="https://img.shields.io/codefactor/grade/github/k3vinb5/unyo?style=for-the-badge&color=03A363"><img src="https://img.shields.io/codefactor/grade/github/k3vinb5/unyo?style=for-the-badge&color=03A363"></a>
<a href="https://img.shields.io/github/downloads/K3vinb5/Unyo/total.svg?style=for-the-badge"><img src="https://img.shields.io/github/downloads/K3vinb5/Unyo/total.svg?style=for-the-badge&color=CAF979"></a>
<a href="https://img.shields.io/github/issues/K3vinb5/Unyo?style=for-the-badge"><img src="https://img.shields.io/github/issues/K3vinb5/Unyo?style=for-the-badge&color=CE5842"></a>
<br>
<a href="https://img.shields.io/badge/Made_For-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=white"><img src="https://img.shields.io/badge/Made_For-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=white"></a>
<a href="https://img.shields.io/badge/Made_For-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white"><img src="https://img.shields.io/badge/Made_For-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white"></a>
<a href="https://img.shields.io/badge/Made_For-Macos-000000?style=for-the-badge&logo=macos&logoColor=white"><img src="https://img.shields.io/badge/Made_For-Macos-000000?style=for-the-badge&logo=macos&logoColor=white"></a>

<br>
<br>
<br>
<br>
<img title="img" alt="img" src="./readme-assets/screenshots.gif">
<br>
<br>

## About Unyo

**Unyo** is a desktop application inspired by [Dantotsu](https://github.com/rebelonion/dantotsu) where you can watch your favourite anime and read your favourite manga. It is fully integrated with AniList, so whatever content you consume will always be synced automatically. It has a great UI and animations, and above all, it's ad-free.

## Unyo's Future

As the commit history shows, Unyo has been stuck for quite a while, with little to no development. A lot of things have changed in my life lately, but I'm finally getting back on track. In the future, I will be more transparent and organized about Unyo's progress. For now, I will resume development slowly so I don't get burned out. Please be patient while you wait for more news.

### Some Updates!

- A new backend is being developed for Unyo to bring back more extensions and improve uptime. It is coming along nicely. Expect more news in the future.
- The backend is pretty much done. I have decided to rewrite the app so it can be more maintainable and less buggy. End users probably haven't noticed, but it had started to show signs of weakness in both performance and developer experience, and new features were very hard to add.

## Installation

You can download the latest version from the [releases](https://github.com/K3vinb5/Unyo/releases/latest) tab.

If you are on **Windows**, you can:

- Download the .zip file, extract it, and run the executable "unyo.exe".
- Download the .exe installer, run it, and follow the instructions.

If you are on **macOS**, you can:

- Download the .dmg file and install it just like any other Mac application.
- Download the .zip file, extract it, and run the .app (not recommended; use the .dmg file instead).

If you are on **Linux**, you can:

- Install the app using the [AM package manager](https://github.com/ivan-hc/AM) by running "am -i unyo" (recommended). You can also update it by running "am -u unyo".
- If you're on an Arch-based distribution, find Unyo in the AUR under the name "unyo-bin".
- Download the .zip file, extract it, and run the executable "unyo".
- Download the .AppImage file and run it.
- Download the .deb file and install the package by running "sudo apt install ./package_name.deb" (Debian-based distributions only).

When setting up Unyo, make sure your AniList profile is set to either public or semi-public. Currently, Unyo won't be able to pull your anime and manga lists if your account is set to private.

## Available Extensions

### Remote Extensions

The remote extensions for this app come from a custom API that uses [Aniyomi](https://github.com/aniyomiorg/aniyomi) extensions. If you wish to have a source added, you can open an issue with the name of the extension, and I'll try to integrate it. Because the original project was for Android, I had to adapt a lot of the codebase to work on PCs. This means that not all extensions will work (most likely a skill issue, to be honest -_-).

### Local Extensions

Local extensions are basically the same as remote extensions, but the API runs on your computer and uses a modular system. The extensions are based on [Aniyomi](https://github.com/aniyomiorg/aniyomi) extensions. If you wish to use local extensions, you can download them through the app from my extensions repository, [Unyo-Extensions](https://github.com/K3vinb5/Unyo-Extensions). Later, I will post some guides and tools to encourage others to contribute extensions. Here are some advantages and disadvantages of using local extensions so you can decide for yourself whether they are worth it:

#### Advantages

- Faster response times
- More extensions, since many work locally but not on the server because of the server's location
- You don't depend on the server

#### Disadvantages

- You need Java 17 or later installed on your machine
- The app will consume more RAM (around 100 to 200 MB)

#### Local Extension Dependencies

You need Java 17 or later installed on your machine to run local extensions. I imagine most people have it, but if you don't, here are the download links:

- Linux: [https://www.oracle.com/java/technologies/downloads/#jdk17-linux](https://www.oracle.com/java/technologies/downloads/#jdk17-linux)
- macOS: [https://www.oracle.com/java/technologies/downloads/#jdk17-mac](https://www.oracle.com/java/technologies/downloads/#jdk17-mac)
- Windows: [https://www.oracle.com/java/technologies/downloads/#jdk17-windows](https://www.oracle.com/java/technologies/downloads/#jdk17-windows)
  
## Known Issues

- The app occasionally crashes in the latest version. These crashes should only occur when leaving videos. If it crashes, relaunch it; you should be able to get back to using it quickly. The issue has been diagnosed and is already on the to-do list under the Projects tab. This should improve in the next version.
- DLL hijacking vulnerability: find more details [here](https://github.com/K3vinb5/Unyo/issues/58).

## Contributors

[![](https://contrib.rocks/image?repo=K3vinb5/Unyo)](https://github.com/K3vinb5/Unyo/graphs/contributors)

Contributions are always welcome! If you have any ideas or changes that you want to see in the app, submit a pull request. If you have suggestions or issues, feel free to open an issue!

Because this has happened before, I will state it explicitly: contributing to the project means submitting a pull request, opening an issue with suggestions, etc. It does not mean proposing a big project that essentially rebrands my app in another repository under your name :D.

## Contributing

Thank you for considering contributing to **Unyo**! Here’s how you can help:

1. **Fork the Repository**: Click the "Fork" button at the top right of this page.
2. **Clone Your Fork**: Run `git clone https://github.com/your-username/repository-name.git` in your terminal.
3. **Create a Branch**: Use `git checkout -b your-branch-name` to create a new branch for your changes.
4. **Make Changes**: Implement your feature or fix and commit your changes with a descriptive message.
5. **Push to Your Branch**: Push your changes using `git push origin your-branch-name`.
6. **Open a Pull Request**: Go to the original repository and submit a new pull request from your branch.

We appreciate your contributions! 😊


## License

This project is licensed under the **GNU Public License version 3.0**. An extra clause states that you must mention this project if you use any portion of its code.
This project contains two very small portions of code from [mangayomi](https://github.com/kodjodevf/mangayomi): the torrent server and an audio slider. A big shout-out to the developer!

## Disclaimer

- By using this app, you agree that Unyo's developers are not responsible for any content within the app and won't be legally responsible for any violations.
- All content in Unyo is hosted by third parties, and the developers are not accountable for its nature or legality. Users are advised to use the application responsibly and in compliance with relevant laws and regulations in their countries.
- Unyo or its developers are not responsible for the misuse of any content within or outside the app and shall not be responsible for the dissemination of any content within the app.
