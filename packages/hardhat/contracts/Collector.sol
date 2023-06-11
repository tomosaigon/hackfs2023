pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

// import "hardhat/console.sol";

// pragma solidity ^0.8.0;
enum ValidatorStatus {
    Undefined,
    Active,
    Inactive
}

interface ValidatorsContract {
    function validatorStatus(address validator) external view returns (bool);
}

contract Collector {
    enum SubmissionStatus { Initial, Rejected, Valid, Paid }

    struct Collection {
        address validator;
        bytes32 publicKey;
        uint256 deposit;
        string request;
        uint256 validationFee;
        uint256 maxParticipants;
        uint256 acceptedSubmissionCount;
    }

    struct Submission {
        uint256 collectionIndex;
        address submitter;
        string uri;
        SubmissionStatus status;
    }

    Collection[] public collections;
    Submission[] public submissions;

    address public validatorsContract;

    constructor(address _validatorsContract) {
        validatorsContract = _validatorsContract;
    }

    function createCollection(
        address _validator,
        bytes32 _publicKey,
        string memory _request,
        uint256 _validationFee,
        uint256 _maxParticipants
    ) public payable {
        ValidatorsContract validators = ValidatorsContract(validatorsContract);
        require(validators.validatorStatus(_validator), "Invalid validator");

        Collection memory newCollection = Collection(
            _validator,
            _publicKey,
            msg.value, // Set deposit value to the amount of Ether sent in the transaction
            _request,
            _validationFee,
            _maxParticipants,
            0
        );

        collections.push(newCollection);
    }

    function createSubmission(
        uint256 _collectionIndex,
        string memory _uri
    ) public {
        require(_collectionIndex < collections.length, "Invalid collection index");
        Collection storage collection = collections[_collectionIndex];

        Submission memory newSubmission = Submission(
            _collectionIndex,
            msg.sender,
            _uri,
            SubmissionStatus.Initial
        );

        submissions.push(newSubmission);

        collection.acceptedSubmissionCount++;
    }
}
