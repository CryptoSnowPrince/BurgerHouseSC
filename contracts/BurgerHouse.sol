// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract BurgerHouse {
    struct House {
        uint256 coins;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8[8] chefs;
    }
    mapping(address => House) public houses;
    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;
    address public manager = msg.sender;

    function addCoins(address ref) public payable {
        uint256 coins = msg.value / 2e13;
        require(coins > 0, "Zero coins");
        address user = msg.sender;
        totalInvested += msg.value;
        if (houses[user].timestamp == 0) {
            totalTowers++;
            ref = houses[ref].timestamp == 0 ? manager : ref;
            houses[ref].refs++;
            houses[user].ref = ref;
            houses[user].timestamp = block.timestamp;
        }
        ref = houses[user].ref;
        houses[ref].coins += (coins * 7) / 100;
        houses[ref].money += (coins * 100 * 3) / 100;
        houses[ref].refDeps += coins;
        houses[user].coins += coins;
        payable(manager).transfer((msg.value * 3) / 100);
    }

    function withdrawMoney() public {
        address user = msg.sender;
        uint256 money = houses[user].money;
        houses[user].money = 0;
        uint256 amount = money * 2e11;
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        houses[user].hrs = 0;
        houses[user].money += houses[user].money2;
        houses[user].money2 = 0;
    }

    function upgradeTower(uint256 floorId) public {
        require(floorId < 8, "Max 8 floors");
        address user = msg.sender;
        syncTower(user);
        houses[user].chefs[floorId]++;
        totalChefs++;
        uint256 chefs = houses[user].chefs[floorId];
        houses[user].coins -= getUpgradePrice(floorId, chefs);
        houses[user].yield += getYield(floorId, chefs);
    }

    function sellTower() public {
        collectMoney();
        address user = msg.sender;
        uint8[8] memory chefs = houses[user].chefs;
        totalChefs -= chefs[0] + chefs[1] + chefs[2] + chefs[3] + chefs[4] + chefs[5] + chefs[6] + chefs[7];
        houses[user].money += houses[user].yield * 24 * 14;
        houses[user].chefs = [0, 0, 0, 0, 0, 0, 0, 0];
        houses[user].yield = 0;
    }

    function getChefs(address addr) public view returns (uint8[8] memory) {
        return houses[addr].chefs;
    }

    function syncTower(address user) internal {
        require(houses[user].timestamp > 0, "User is not registered");
        if (houses[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - houses[user].timestamp / 3600;
            if (hrs + houses[user].hrs > 24) {
                hrs = 24 - houses[user].hrs;
            }
            houses[user].money2 += hrs * houses[user].yield;
            houses[user].hrs += hrs;
        }
        houses[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 floorId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][floorId];
        if (chefId == 2) return [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][floorId];
        if (chefId == 3) return [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][floorId];
        if (chefId == 4) return [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][floorId];
        if (chefId == 5) return [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][floorId];
        revert("Incorrect chefId");
    }

    function getYield(uint256 floorId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][floorId];
        if (chefId == 2) return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][floorId];
        if (chefId == 3) return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][floorId];
        if (chefId == 4) return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][floorId];
        if (chefId == 5) return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][floorId];
        revert("Incorrect chefId");
    }
}