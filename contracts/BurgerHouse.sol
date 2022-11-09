// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract BurgerHouse {
    struct House {
        uint256 coins;
        uint256 cash;
        uint256 burger;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refCoins;
        uint8[8] levels;
    }
    mapping(address => House) public houses;
    uint256 public totalUpgrades;
    uint256 public totalHouses;
    uint256 public totalInvested;
    address public manager = msg.sender;

    function addCoins(address _ref) public payable {
        uint256 coins = msg.value / 2e13;
        require(coins > 0, "Zero coins");
        address user = msg.sender;
        totalInvested += msg.value;
        if (houses[user].timestamp == 0) {
            totalHouses++;
            _ref = houses[_ref].timestamp == 0 ? manager : _ref;
            houses[_ref].refs++;
            houses[user].ref = _ref;
            houses[user].timestamp = block.timestamp;
        }
        _ref = houses[user].ref;
        houses[_ref].coins += (coins * 7) / 100;
        houses[_ref].cash += (coins * 100 * 3) / 100;
        houses[_ref].refCoins += coins;
        houses[user].coins += coins;
        payable(manager).transfer((msg.value * 3) / 100);
    }

    function withdrawMoney() public {
        address user = msg.sender;
        uint256 cash = houses[user].cash;
        houses[user].cash = 0;
        uint256 amount = cash * 2e11;
        payable(user).transfer(
            address(this).balance < amount ? address(this).balance : amount
        );
    }

    function collectMoney() public {
        address user = msg.sender;
        _makeBurgers(user);
        houses[user].hrs = 0;
        houses[user].cash += houses[user].burger;
        houses[user].burger = 0;
    }

    function upgradeHouse(uint256 _houseId) public {
        require(_houseId < 8, "Max 8 floors");
        address user = msg.sender;
        _makeBurgers(user);
        houses[user].levels[_houseId]++;
        totalUpgrades++;
        uint256 level = houses[user].levels[_houseId];
        houses[user].coins -= getUpgradePrice(_houseId, level);
        houses[user].yield += getYield(_houseId, level);
    }

    function sellHouse() public {
        collectMoney();
        address user = msg.sender;
        uint8[8] memory levels = houses[user].levels;
        totalUpgrades -=
            levels[0] +
            levels[1] +
            levels[2] +
            levels[3] +
            levels[4] +
            levels[5] +
            levels[6] +
            levels[7];
        houses[user].cash += houses[user].yield * 24 * 14;
        houses[user].levels = [0, 0, 0, 0, 0, 0, 0, 0];
        houses[user].yield = 0;
    }

    function getLevels(address addr) public view returns (uint8[8] memory) {
        return houses[addr].levels;
    }

    function _makeBurgers(address user) internal {
        require(houses[user].timestamp > 0, "User is not registered");
        if (houses[user].yield > 0) {
            uint256 hrs = (block.timestamp - houses[user].timestamp) / 3600;
            if (hrs + houses[user].hrs > 24) {
                hrs = 24 - houses[user].hrs;
            }
            houses[user].burger += hrs * houses[user].yield;
            houses[user].hrs += hrs;
        }
        houses[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 _houseId, uint256 _level)
        public
        pure
        returns (uint256)
    {
        if (_level == 1)
            return
                [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][
                    _houseId
                ];
        if (_level == 2)
            return
                [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][
                    _houseId
                ];
        if (_level == 3)
            return
                [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][
                    _houseId
                ];
        if (_level == 4)
            return
                [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][
                    _houseId
                ];
        if (_level == 5)
            return
                [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][
                    _houseId
                ];
        revert("Incorrect _level");
    }

    function getYield(uint256 _houseId, uint256 _level)
        private
        pure
        returns (uint256)
    {
        if (_level == 1)
            return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][_houseId];
        if (_level == 2)
            return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][_houseId];
        if (_level == 3)
            return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][_houseId];
        if (_level == 4)
            return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][_houseId];
        if (_level == 5)
            return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][_houseId];
        revert("Incorrect _level");
    }
}
