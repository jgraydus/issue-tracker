module Issues.Lib.Web.JsBundle (
  jsBundle
) where

import qualified Data.ByteString as BS
import           Data.Text (Text)
import           Data.Text.Encoding (decodeUtf8)

jsBundleFilePath :: FilePath
jsBundleFilePath = "client/build/bundle.js"

jsBundle :: IO Text
jsBundle = decodeUtf8 <$> BS.readFile jsBundleFilePath

