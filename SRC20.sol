// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
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

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
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

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */

     //just public function where we paste our values, all the logic in internal function
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

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
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

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */

    //simple transfer event that checks that the receiver is not zero wallet (as this is burning token - so we should better call burn()) and to - is not zero wallet as we are not minting tokens - we are transfering them
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    //update checkes of we receive from zero wallet (minted tokens), or sent to zero wallet (burned tokens)
    function _update(address from, address to, uint256 value) internal virtual {
        //there we checked whether we receive funds from zero wallet - in other words we mint funds
        if (from == address(0)) {
            //if we really received from zero wallet - we increase the total supply
            _totalSupply += value;
        } else {
            //in other cases we look in the mapping for the wallet that sent, check it's balance and make sure it has sufficient funds to proccess tx
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                //if not - we revert
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                //if it is sufficient - we remove decrese the value of the balance the mapping
                _balances[from] = fromBalance - value;
            }
        }

        //the same story with the burning, if we send to zero wallet - then me remove these tokens from the supply
        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                //if it is not zero wallet then we increase the balance by the value we receive from "from" wallet
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        //just check that we are not sending to the zero address while minting tokens (as we are actually minting them - not burning)
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        //when we mint we send amount from address(0)
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        //check the line in the mint condition - the same for that but vice versa
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        //when we burn we send the funds to the zero address 0x00000.....
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */

     //in this function we call another _approve func with 4params but we set emitEvent to true by default
     //so every _approve function that we will call with 3 parameters will call _approve with 4 params and the last emitEvent will be true by default
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    //function to emit an Approval event
    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        //doing a number of checks and then emits an Approval event
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        // we set current allowance of the user, that we received
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        //receive current allowance of the current user
        uint256 currentAllowance = allowance(owner, spender);
        //to avoid overflow
        if (currentAllowance != type(uint256).max) {
            //to check if we want to spend more that we are allowed to
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            //so we are not emitting an Approvl
            //currentAllowance - value - so we are subtrating currentAllowance as we spent it
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
