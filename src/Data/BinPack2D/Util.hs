module Data.BinPack2D.Util (packInSize, packRect)
where

import Control.Arrow (Arrow (first, (&&&), (***)))
import Data.BinPack2D (
  Bin,
  Position (positionX, positionY),
  Size (Size),
  emptyBin,
  pack,
 )
import Data.Either (rights)

packInSize :: Size -> [Size] -> Either String [Position]
packInSize totalSize sizes = fst <$> packing sizes (emptyBin totalSize)
 where
  packing :: [Size] -> Bin -> Either String ([Position], Bin)
  packing (s : ss) b0 =
    case pack s b0 of
      Nothing -> Left ("packing error at: " <> show (s, b0))
      Just (pos, b1) -> first (<> [pos]) <$> packing ss b1
  packing [] b0 = pure ([], b0)

-- | pack info 2^n size rect
packRect' :: [Size] -> (Word, [Position])
packRect' sizes =
  head $ rights $ (\s -> (s,) <$> packInSize (Size s s) sizes) <$> allRect
 where
  allRect = (2 ^) <$> [4 :: Word ..]

-- | pack info 2^n size rect
packRect ::
  -- | sizes
  [(Int, Int)] ->
  -- | (final size, positions)
  (Int, [(Int, Int)])
packRect sizes = fromIntegral *** fmap fromPosition $ packRect' (toSize <$> sizes)
 where
  fromPosition = fromIntegral . positionX &&& fromIntegral . positionY
  toSize (w, h) = Size (fromIntegral w) (fromIntegral h)