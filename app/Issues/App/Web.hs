module Issues.App.Web where

import qualified Network.Wai.Handler.Warp as Warp
import           System.Exit (ExitCode(..), exitWith)

import           Issues.Lib.Language.Interpreter.InMemory (withRunTime)
import           Issues.Lib.Logger (LogLevel(INFO), newLogger, toLogStr)
import           Issues.Lib.Config (ApplicationConfig(..), HttpConfig(..), readConfig)
import           Issues.Lib.Web.Application
import           Issues.Lib.Web.Options

main :: IO ()
main = do
  -- parse the command line options
  Options {..} <- parseOptions

  -- read the application configuration files
  config <- readConfig _optionsConfigDir (env _optionsMode)

  case config of
    Left errorMessage -> do
      putStrLn errorMessage
      exitWith (ExitFailure 1)
      
    Right c@ApplicationConfig {..} -> do
      let HttpConfig {..} = _applicationConfigHttp
      (logger, loggerCleanup) <- newLogger _applicationConfigLogLevel

      logger INFO (toLogStr $ "server listening on port " <> show _httpConfigPort)

      withRunTime $ \rt -> Warp.run _httpConfigPort (app c rt logger)

      _ <- loggerCleanup
      exitWith ExitSuccess

