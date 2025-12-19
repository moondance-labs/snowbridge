//SPDX-License-Identifier: GPL-3.0-or-later

// Copyright (C) Moondance Labs Ltd.
// This file is part of Tanssi.
// Tanssi is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// Tanssi is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with Tanssi.  If not, see <http://www.gnu.org/licenses/>
pragma solidity 0.8.28;

library GatewayCoreStorage {
    // Emitted when owner of the gateway is changed.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Emitted when the middleware contract address is changed by the owner.
    event MiddlewareChanged(address indexed previousMiddleware, address indexed newMiddleware);

    error CantSetMiddlewareToZeroAddress();
    error CantSetMiddlewareToSameAddress();

    struct Layout {
        // Owner of the gateway for configuration purposes.
        address owner;
        // Address of the Symbiotic middleware to properly execute messages.
        address middleware;
    }

    bytes32 internal constant SLOT = keccak256("tanssi-bridge-relayer.gateway.core");

    function layout() internal pure returns (Layout storage ptr) {
        bytes32 slot = SLOT;
        assembly {
            ptr.slot := slot
        }
    }

    function transferOwnership(address newOwner) external {
        Layout storage l = layout();
        address previousOwner = l.owner;
        l.owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    /// Changes the middleware address.
    function setMiddleware(address middleware) external {
        Layout storage l = layout();
        address oldMiddleware = l.middleware;

        if (middleware == address(0)) {
            revert CantSetMiddlewareToZeroAddress();
        }

        if (middleware == oldMiddleware) {
            revert CantSetMiddlewareToSameAddress();
        }

        l.middleware = middleware;
        emit MiddlewareChanged(oldMiddleware, middleware);
    }

    function s_middleware() external view returns (address) {
        Layout storage l = layout();
        return l.middleware;
    }
}
