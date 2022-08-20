module GenerateJsBindings where

import           ApiV1 
import           Auth
import           Control.Lens ((&), (<>~))
import           Data.Proxy
import           Data.Text (Text)
import qualified Data.Text.IO as Text
import           Servant.Foreign
import           Servant.JS
import           Servant.JS.Axios

instance HasForeignType lang ftype JwtAuth where
  typeFor l t a = typeFor l t a

instance HasForeign NoTypes NoContent api => HasForeign NoTypes NoContent (JwtAuth :> api) where
  type Foreign NoContent (JwtAuth :> api) = Foreign NoContent api
  foreignFor l f _ req = foreignFor l f p $ req & reqHeaders <>~ [HeaderArg arg]
    where
      p :: Proxy api = Proxy
      arg = Arg { _argName = PathSegment "x-bearer-token",
                  _argType = typeFor l f (Proxy :: Proxy NoContent) }

api :: Proxy API_V1
api = Proxy

axiosOptions :: AxiosOptions
axiosOptions = AxiosOptions
  { withCredentials = False
  , xsrfCookieName = Nothing
  , xsrfHeaderName = Nothing
  }

commonOptions :: CommonGeneratorOptions
commonOptions = defCommonGeneratorOptions
  { moduleName = "exports"
  }

outFilePath :: FilePath
outFilePath = "client/src/generated/bindings.js"

axiosImport :: Text
axiosImport = "import axios from 'axios'\n\n"

writeJSCode :: IO ()
writeJSCode = do
  let js = jsForAPI api (axiosWith axiosOptions commonOptions)
  Text.writeFile outFilePath (axiosImport <> js) 
