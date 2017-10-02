# Bluemera

Bluemera allows you to make a photo send and then share it with another through bluetooth. This project aims to show that we are excellent students that deserve a nice grade :-).

Collaboration between:

- [Ramon schriks](https://github.com/ramonschriks)
- [Iain Munro](https://github.com/iain17)

## Dependencies

We made use of [cocoapods](cocoapods.org) to make our lifes a little easier.

- [BluetoothKit](https://cocoapods.org/pods/BluetoothKit): This simplifies chunking the data sent and received between users over low energy bluetooth.

## Usage

1. Run ```pod install```
2. Open the **Bluemera.xcworkspace** file.
3. Enjoy!

Note: This project wil not work in the emulator.


### Grading (Dutch)

|   | Must                                                                          | Punten | Max. cijfer |
|---|-------------------------------------------------------------------------------|--------|-------------|
| A | Maak foto met de camera                                                       | 1.0    |             |
| B | Verstuur gemaakte foto via Bluetooth,Low Energy naar app van klasgenoot       | 1.5    |             |
| C | Ontvang foto via Bluetooth Low Energy van app van klasgenoot                  | 1.0    |             |
| D | Sla ontvangen foto op in “Photos”                                             | 1.5    |             |
|   |                                                                               |        | 5           |
|   | Should                                                                        |        |             |
| E | Zorg ervoor dat je UI niet blokkeert (multi-threading)                        | 1.0    |             |
| F | Zorg voor toepassing van goede OO principes (loose coupling, strong cohesion) | 1.0    |             |
|   |                                                                               |        | 7           |
|   | Could (pick and choose)                                                       |        |             |
| G | Zorg ervoor dat fotos GPS data bevatten                                       | 0.2    |             |
| H | Geef gps data weer na ontvangen van foto van ander                            | 0.2    |             |
| I | Verzenden/ontvangen/opslaan van andere bestandstypes                          | 1.0    |             |
| J | Gebruik maken van een cocoapods (spinner o.i.d.)                              | 0.5    |             |
| K | Gebruik maken van de IOS 11 files app                                         | 1.0    |             |
| L | In plaats van B/C kun je de,gemaakte foto ook via WiFi uitwisselen.           | 1.5    |             |
|   |                                                                               |        | 10          |

N.b. 1 As always: Aftrek voor slordig programmeren is mogelijk. <br>
N.b. 2 Te laat: max 2 dagen (<= 10 Okt. 24:00 gecommit) -1, > 2 dagen -2.


## License
Bluemera is released under the MIT License.