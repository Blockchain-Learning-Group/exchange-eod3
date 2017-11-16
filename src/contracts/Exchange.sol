pragma solidity ^0.4.15;

import './token/ERC20.sol';

/**
 * @title Minimalistic Decentralized Exchange
 * @dev Enables user selected orders to execute and be completely filled.
 */
contract Exchange {
  /**
   * Data Structures
   */
  struct Order {
    address maker;
    address bidToken;
    uint256 bidAmount;
    address askToken;
    uint256 askAmount;
  }

  /**
   * Storage
   */
  /***********************************
  * Create a mapping to store orders *
  ***********************************/
  mapping(bytes32 => Order) public orderBook_;

  /**
   * Events
   */
  event LogOrderSubmitted (
    bytes32 id,
    address maker,
    address bidToken,
    uint256 bidAmount,
    address askToken,
    uint256 askAmount
  );

  event LogOrderExecuted (
    bytes32 id,
    address maker,
    address taker,
    address bidToken,
    uint256 bidAmount,
    address askToken,
    uint256 askAmount
  );

  /**
   * @dev Fallback.  Enable This contract to be sent ether.
   */
  function() payable { }

  /**
   * @dev Submit a new order to the exchange.
   * The exchange only supports the sale of tokens for ether!
   * The only pairing supported is TOK / ETH.
   */
  function submitOrder (
    address _bidToken,
    uint256 _bidAmount,
    address _askToken,
    uint256 _askAmount
  ) external
  {
    /************************************************************
    * Sufficent token balance, allowance, given to the exchange *
    ************************************************************/
    require(ERC20(_bidToken).allowance(msg.sender, this) >= _bidAmount);

    /***************************************
    * Confirm order does not already exist *
    ***************************************/
    bytes32 orderId = keccak256(_bidToken, _bidAmount, _askToken, _askAmount);
    require(orderBook_[orderId].askAmount == 0); // check for existence, default to 0

    /******************************
    * Add order to the order book *
    ******************************/
    orderBook_[orderId] = Order({
      maker: msg.sender,
      bidToken: _bidToken,
      bidAmount: _bidAmount,
      askToken: _askToken,
      askAmount: _askAmount
    });

    LogOrderSubmitted(orderId, msg.sender, _bidToken,_bidAmount, _askToken, _askAmount);
  }

  /**
   * @dev Execute an order that has been matched.
   * NOTE msg.sender is the taker. Only allows complete fills.
   */
  function executeOrder (
    bytes32 _orderId
  ) external
    payable
  {
    /*******************************************************
    * Load the order into mem, save gas on read operations *
    *******************************************************/
    Order memory order = orderBook_[_orderId];

    /*********************************************
    * Confirm the taker sent the correct balance *
    *********************************************/
    require(msg.value == order.askAmount);

    /********************
    * Execute the trade *
    ********************/
    order.maker.transfer(order.askAmount);
    require(ERC20(order.bidToken).transferFrom(order.maker, msg.sender, order.bidAmount));

    /*******************
    * Remove the order *
    *******************/
    delete orderBook_[_orderId];

    LogOrderExecuted(_orderId, order.maker, msg.sender, order.bidToken, order.bidAmount, order.askToken, order.askAmount);
  }
}
