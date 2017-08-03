import Data.Blob
import Data.ByteString.Char8 (ByteString, pack)
import Data.Maybe (fromMaybe)
import Data.Monoid (Sum(..))
import Data.Output
import Data.Range
import Data.Semigroup ((<>))
import Data.Source
import Prelude hiding (fst, snd)
truncatePatch :: Both Blob -> ByteString
renderPatch :: (HasField fields Range, Traversable f) => Both Blob -> Diff f (Record fields) -> File
instance Output File where
  toOutput = unFile
showHunk :: Functor f => HasField fields Range => Both Blob -> Hunk (SplitDiff f (Record fields)) -> ByteString
  where sources = blobSource <$> blobs
        offsetHeader = "@@ -" <> offsetA <> "," <> pack (show lengthA) <> " +" <> offsetB <> "," <> pack (show lengthB) <> " @@" <> "\n"
        (offsetA, offsetB) = runJoin . fmap (pack . show . getSum) $ offset hunk
showLine source line | Just line <- line = Just . sourceBytes . (`slice` source) $ getRange line
header :: Both Blob -> ByteString
        modeHeader :: ByteString -> Maybe BlobKind -> ByteString -> ByteString
        maybeFilepaths = if (nullOid == oidA && nullSource (snd sources)) || (nullOid == oidB && nullSource (fst sources)) then [] else [ beforeFilepath, afterFilepath ]
        sources = blobSource <$> blobs
        (pathA, pathB) = case runJoin $ pack . blobPath <$> blobs of
        (oidA, oidB) = runJoin $ blobOid <$> blobs
hunks :: (Traversable f, HasField fields Range) => Diff f (Record fields) -> Both Blob -> [Hunk (SplitDiff [] (Record fields))]
hunks _ blobs | sources <- blobSource <$> blobs
              , sourcesNull <- runBothWith (&&) (nullSource <$> sources)
hunks diff blobs = hunksInRows (pure 1) $ alignDiff (blobSource <$> blobs) diff