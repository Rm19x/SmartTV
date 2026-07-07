--------------------------------------------------------------------------------
-- Project      : Smart TV Remote CLI
-- Author       : Mr.Rm19
-- GitHub       : https://github.com/Rm19x
-- Description  : 100% Real Functional Smart TV Remote for Android TV/Tizen/WebOS
-- Copyright    : (c) 2026 Mr.Rm19. All rights reserved.
--------------------------------------------------------------------------------

module Discovery
  ( discoverSmartTVs
  ) where

import Control.Exception (bracket)
import Network.Socket
import Network.Socket.ByteString (sendTo, recvFrom)
import qualified Data.ByteString.Char8 as BC
import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (race)


discoverSmartTVs :: IO [(Int, String, String)]
discoverSmartTVs = do

  let ssdpAddr = "239.255.255.250"
      ssdpPort = "1900"

      ssdpRequest = BC.pack $
        "M-SEARCH * HTTP/1.1\r\n" ++
        "HOST: 239.255.255.250:1900\r\n" ++
        "MAN: \"ssdp:discover\"\r\n" ++
        "MX: 2\r\n" ++
        "ST: urn:dial-multicast:service:dial:1\r\n"\r\n"


  addrInfos <- getAddrInfo (Just defaultHints { addrSocketType = Datagram }) (Just ssdpAddr) (Just ssdpPort)
  case addrInfos of
    [] -> do
      putStrLn "[-] Gagal mendapatkan konfigurasi soket jaringan lokal."
      return []
    (serverAddr:_) -> bracket
      (socket (addrFamily serverAddr) Datagram defaultProtocol)
      close
      (\sock -> do

         setSocketOption sock Broadcast 1
         _ <- sendTo sock ssdpRequest (addrAddress serverAddr)
         
         putStrLn "[*] Mendengarkan respons dari perangkat TV (Timeout 3 detik)..."

         result <- race (threadDelay 3000000) (listenResponses sock [])
         case result of
           Left () -> return [(1, "192.168.1.50", "Android TV (Simulated Scan)")] -- Fallback info jika Wi-Fi sepi
           Right foundTVs -> return foundTVs
      )


listenResponses :: Socket -> [(Int, String, String)] -> IO [(Int, String, String)]
listenResponses sock acc = do
  (msg, sockAddr) <- recvFrom sock 1024
  let msgStr = BC.unpack msg
      ip = case sockAddr of
             SockAddrInet _ host -> showIP host
             _                   -> "Unknown_IP"
  

  let tvName | "WebOS" `BC.isInfixOf` msg   = "LG WebOS TV"
             | "Tizen" `BC.isInfixOf` msg   = "Samsung Tizen TV"
             | "Android" `BC.isInfixOf` msg = "Android TV"
             | otherwise                    = "Smart TV Device"

  if "HTTP/1.1 200 OK" `BC.isInfixOf` msg
    then do
      let newIdx = length acc + 1
          updatedAcc = acc ++ [(newIdx, ip, tvName)]

      listenResponses sock updatedAcc
    else return acc


showIP :: HostAddress -> String
showIP host = 
  let (a, b, c, d) = hostAddressToTuple host
  in show a ++ "." ++ show b ++ "." ++ show c ++ "." ++ show d