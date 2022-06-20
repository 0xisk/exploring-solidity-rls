// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import { ModexpInverse, ModexpSqrt } from "./ModExp.sol";
import {
    BNPairingPrecompileCostEstimator
} from "./BNPairingPrecompileCostEstimator.sol";

library BLS {
    // Field order
    uint256 private constant N = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    
    // Negated generator of G2
    // prettier-ignore
    uint256 private constant N_G2_X1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    // prettier-ignore
    uint256 private constant N_G2_X0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    // prettier-ignore
    uint256 private constant N_G2_Y1 = 17805874995975841540914202342111839520379459829704422454583296818431106115052;
    // prettier-ignore
    uint256 private constant N_G2_Y0 = 13392588948715843804641432497768002650278120570034223513918757245338268106653;

    // sqrt(-3)
    // prettier-ignore
    uint256 private constant Z0 = 0x0000000000000000b3c4d79d41a91759a9e4c7e359b6b89eaec68e62effffffd;
    // (sqrt(-3) - 1)  / 2
    // prettier-ignore
    uint256 private constant Z1 = 0x000000000000000059e26bcea0d48bacd4f263f1acdb5c4f5763473177fffffe;

    // prettier-ignore
    uint256 private constant T24 = 0x1000000000000000000000000000000000000000000000000;
    // prettier-ignore
    uint256 private constant MASK24 = 0xffffffffffffffffffffffffffffffffffffffffffffffff;

    // estimator address
    address private constant COST_ESTIMATOR_ADDRESS =
        0x079d8077C465BD0BF0FC502aD2B846757e415661;

    function verifySingle(
        uint256[2] memory signature,
        uint256[4] memory pubkey,
        uint256[2] memory message
    ) internal view returns (bool, bool) {
        uint256[12] memory input = 
            [
                signature[0],
                signature[1],
                N_G2_X1,
                N_G2_X0,
                N_G2_Y1,
                N_G2_Y0, 
                message[0],
                message[1],
                pubkey[1],
                pubkey[0],
                pubkey[3],
                pubkey[2]
            ];
        
        uint256[1] memory out;
        uint256 precompileGasCost = 
            BNPairingPrecompileCostEstimator(COST_ESTIMATOR_ADDRESS).getGasCost(
                2
            );
        
        bool callSuccess;

        assembly {
            callSuccess := staticcall(
                precompileGasCost,
                8,
                input, 
                384, 
                out, 
                0x20
            )
        }

        if(!callSuccess) {
            return (false, false);
        }

        return (out[0] != 0, true);
    }
}