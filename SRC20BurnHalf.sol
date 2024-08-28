// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors, Ownable {
    //mapping for the balances of the wallets that own that token
    mapping(address account => uint256) private _balances;
    //mapping of the allowances of the token
    mapping(address account => mapping(address spender => uint256))
        private _allowances;
    //totalSupply of the created token
    uint256 private _totalSupply;
    //name of the token
    string private _name;
    //symbol of the token
    string private _symbol;

    //initialized name and symbol of the token while creation
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    //get the name of the token
    function name() public view virtual returns (string memory) {
        return _name;
    }

    //get the symbol of the token
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    //see the balance of the user of our token
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    //transfer our token (it is public, all the func is done in internal _transfer)
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    //show an amount of tokens that spender can spend of the owner balance
    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 value
    ) public virtual returns (bool) {
        //create a variable owner that hold the value of msg.sender
        address owner = _msgSender();
        //owner - person that owns tokens , spender - the person that will be able to spend these amount of tokens that we allowed
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        //we pass the values to the _transfer function where we complete a number of checkes and then _transfer will paste vals to _update and we will update our mapping and initialize the final transfer (sender will have smaller balance as he sent funcds, receiver receives an amount transfered to him )
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function burnHalf() public onlyOwner {
        _burnHalf(msg.sender);
    }

    function _burnHalf(address account) internal{
        //check the line in the mint condition - the same for that but vice versa
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        //when we burn we send the funds to the zero address 0x00000.....
        _update(account, address(0), totalSupply() / 2);
    }

   
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

   
    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

   
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
