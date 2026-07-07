--------------------------------------------------------------------------------
-- Project      : Smart TV Remote CLI
-- Author       : Mr.Rm19
-- GitHub       : https://github.com/Rm19x
-- Description  : 100% Real Functional Smart TV Remote for Android TV/Tizen/WebOS
-- Copyright    : (c) 2026 Mr.Rm19. All rights reserved.
--------------------------------------------------------------------------------

module Main (main) where

import Control.Monad (void, when)
import Data.Maybe (fromMaybe)
import Options.Applicative
import System.Exit (exitSuccess)


import Config
import Discovery
import Types
import qualified Drivers.AndroidTV as Android
import qualified Drivers.Tizen as Tizen
import qualified Drivers.WebOS as WebOS


data CLIOptions = CLIOptions
  { cmdCommand :: Command
  }

data Command
  = Scan
  | Connect !String !String -- IP dan Tipe TV (android, tizen, webos)
  | SendCmd !String !String !TVCommand -- IP, Tipe, dan Perintah Spesifik
  | Alias !String !String -- Nama Alias dan Perintah Asli


optionsParser :: Parser CLIOptions
optionsParser = CLIOptions <$> subparser
  ( command "scan" (info (pure Scan) (progDesc "Cari Smart TV secara otomatis di jaringan Wi-Fi"))
 <> command "connect" (info connectParser (progDesc "Masuk ke Mode Interaktif dengan TV tertentu"))
 <> command "send" (info sendParser (progDesc "Kirim satu perintah spesifik ke TV"))
 <> command "alias" (info aliasParser (progDesc "Buat perintah singkat (alias) khusus ( 50)"))
  )
  where
    connectParser = Connect
      <$> strOption (long "ip" <> short 'i' <> metavar "IP_ADDRESS" <> help "Alamat IP Smart TV")
      <*> strOption (long "type" <> short 't' <> metavar "TV_TYPE" <> help "Tipe TV (android/tizen/webos)")

    sendParser = SendCmd
      <$> strOption (long "ip" <> short 'i' <> metavar "IP_ADDRESS" <> help "Alamat IP Smart TV")
      <*> strOption (long "type" <> short 't' <> metavar "TV_TYPE" <> help "Tipe TV (android/tizen/webos)")
      <*> argument customCommandReader (metavar "COMMAND" <> help "Perintah (power, volup, voldown, mute, play, pause, reboot, dll)")

    aliasParser = Alias
      <$> strOption (long "name" <> short 'n' <> metavar "ALIAS_NAME" <> help "Nama alias baru (misal: yt)")
      <*> strOption (long "target" <> short 'g' <> metavar "TARGET" <> help "Perintah asli TV")


customCommandReader :: ReadM TVCommand
customCommandReader = eitherReader $ \case
  "power"   -> Right PowerToggle
  "volup"   -> Right VolumeUp
  "voldown" -> Right VolumeDown
  "mute"    -> Right MuteToggle
  "reboot"  -> Right Reboot
  "panic"   -> Right Panic
  _         -> Left "Perintah tidak dikenal. Gunakan: power, volup, voldown, mute, reboot, panic."

--  Tool Mr.Rm19
main :: IO ()
main = do
  putStrLn "======================================================="
  putStrLn "      Smart TV Remote CLI v0.1.0.0 - By Mr.Rm19        "
  putStrLn "          https://github.com/Rm19x/tv-remote-cli       "
  putStrLn "======================================================="
  

  opts <- execParser (info (optionsParser <**> helper) (fullDesc <> progDesc "Aplikasi Remote TV Nyata berbasis CLI oleh Mr.Rm19"))
  

  config <- loadConfig
  
  case cmdCommand opts of
    Scan -> do
      putStrLn "[*] Memulai pencarian Smart TV di jaringan Wi-Fi lokal..."
      tvs <- discoverSmartTVs
      if null tvs
        then putStrLn "[-] Tidak ada Smart TV yang ditemukan otomatis. Coba pairing manual ( 2)."
        else mapM_ (\(idx, ip, name) -> putStrLn $ show idx ++ ". [" ++ name ++ "] -> IP: " ++ ip) tvs

    Connect ip tvType -> do
      putStrLn $ "[*] Menghubungkan ke " ++ tvType ++ " TV di " ++ ip ++ "..."

      let token = lookupToken ip config
      putStrLn "[*] Membuka Mode Interaktif ( 4). Tekan tombol keyboard untuk mengendalikan TV secara langsung."
      runInteractiveMode ip tvType token

    SendCmd ip tvType tvCmd -> do
      let token = lookupToken ip config
      putStrLn $ "[*] Mengirim perintah ke TV di " ++ ip
      executeSingleCommand ip tvType tvCmd token

    Alias name target -> do
      putStrLn $ "[*] Membuat perintah alias baru ( 50): " ++ name ++ " -> " ++ target
      saveAlias name target
      putStrLn "[+] Alias berhasil disimpan!"

executeSingleCommand :: String -> String -> TVCommand -> Maybe String -> IO ()
executeSingleCommand ip "android" tvCmd _ = Android.sendAndroidCommand ip tvCmd
executeSingleCommand ip "tizen" tvCmd token = Tizen.sendTizenCommand ip tvCmd token
executeSingleCommand ip "webos" tvCmd token = WebOS.sendWebOSCommand ip tvCmd token
executeSingleCommand _ _ _ _ = putStrLn "[-] Tipe TV salah. Hanya mendukung: android, tizen, webos."

runInteractiveMode :: String -> String -> Maybe String -> IO ()
runInteractiveMode ip tvType token = do
  putStrLn "[Petunjuk] Panah = Navigasi | Enter = OK | Esc = Keluar | V = Vol Up | C = Vol Down"
  let loop = do
        putStr "remote-cli> "
        input <- getLine
        when (input /= "exit") $ do
          case input of
            "w" -> executeSingleCommand ip tvType MoveUp token
            "s" -> executeSingleCommand ip tvType MoveDown token
            "a" -> executeSingleCommand ip tvType MoveLeft token
            "d" -> executeSingleCommand ip tvType MoveRight token
            _   -> putStrLn "[*] Gunakan tombol navigasi yang sesuai atau ketik 'exit' untuk keluar."
          loop
  loop
  putStrLn "\n[+] Keluar dari Mode Interaktif. Terima kasih Mr.Rm19!"
  exitSuccess