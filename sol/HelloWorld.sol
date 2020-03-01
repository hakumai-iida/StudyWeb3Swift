pragma solidity >= 0.5.0 < 0.7.0;

contract HelloWorld {
	string public word;

  	constructor( string memory _word ) public {
  		word = _word;
  	}

  	function getWord() public view returns( string memory ){
  		return( word );
  	}

  	function setWord( string memory _word ) public {
  		word = _word;
  	}
}
