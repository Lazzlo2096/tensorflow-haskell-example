-- | Simple linear regression example for the README.

import Lib(someFunc)

import Control.Monad (replicateM, replicateM_, zipWithM)
import System.Random (randomIO)
import Test.HUnit (assertBool)

import qualified TensorFlow.Core as TF
import qualified TensorFlow.GenOps.Core as TF
import qualified TensorFlow.Gradient as TF
import qualified TensorFlow.Ops as TF

import qualified Data.Random.Normal as Normal
import qualified Statistics.Sample as Stat
import qualified Data.Vector as Vector
import Text.Printf

dump (x,y) = printf "%f\t%f\n" x y


-- | R² of the model Ŷ = aX+b
-- Note that 'TF.gradient' doesn't even support Double's...
linearModelRSquared :: [Float] -> [Float] -> Float -> Float
                    -> Float
linearModelRSquared xs ys a b = 1 - ssRes / ssTot
        where
                es    = zipWith (-) ys yHats
                yHats = [ a*x+b | x <- xs ]
                -- realToFrac is only ok in this situation
                yMean = realToFrac $ Stat.mean $ Vector.fromList $ (map realToFrac ys)
                ssTot = sum [ (y - yMean) ^ 2 | y <- ys ]
                ssReg = sum [ (y - yMean) ^ 2 | y <- yHats ]
                ssRes = sum [ e ^ 2 | e <- es ]


main :: IO ()
main = do
        noise <- replicateM 100 (Normal.normalIO' (0, 0.001))

        let xData = tail [0,0.01..1]
            yData = [ 3*x + 8 + e | (x,e) <- zip xData noise]

       -- Fit linear regression model.
        (w, b) <- fit xData yData

       -- Calculate and print the R-squared for this model
        let rSquared = linearModelRSquared xData yData w b
        printf "R^2 = %f\n" rSquared


fit :: [Float] -> [Float] -> IO (Float, Float)
fit xData yData = TF.runSession $ do
    -- Create tensorflow constants for x and y.
    let x = TF.vector xData
        y = TF.vector yData
    -- Create scalar variables for slope and intercept.
    w <- TF.initializedVariable 0
    b <- TF.initializedVariable 0
    -- Define the loss function.
    let yHat = (x `TF.mul` w) `TF.add` b
        loss = TF.square (yHat `TF.sub` y)
    -- Optimize with gradient descent.
    trainStep <- gradientDescent 0.001 loss [w, b]
    replicateM_ 1000 (TF.run trainStep)
    -- Return the learned parameters.
    (TF.Scalar w', TF.Scalar b') <- TF.run (w, b)
    return (w', b')

gradientDescent :: Float
                -> TF.Tensor TF.Build Float
                -> [TF.Tensor TF.Ref Float]
                -> TF.Session TF.ControlNode
gradientDescent alpha loss params = do
    let applyGrad param grad =
            TF.assign param (param `TF.sub` (TF.scalar alpha `TF.mul` grad))
    TF.group =<< zipWithM applyGrad params =<< TF.gradients loss params
