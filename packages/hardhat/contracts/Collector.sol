pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

// import "hardhat/console.sol";

enum ValidatorStatus {
    Undefined,
    Active,
    Inactive
}

interface ValidatorsContract {
    function validatorStatus(address validator) external view returns (ValidatorStatus);
}

contract Collector {
    enum SubmissionStatus {
        Initial,
        Accepted,
        Rejected
    }

    enum OfferStatus {
        Pending,
        Accepted,
        Rejected
    }

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

    struct Offer {
        uint256 collectionIndex;
        uint256 deposit;
        string requestURI;
        bytes32 publicKey;
        OfferStatus status;
        string resultURI;
    }

    Collection[] public collections;
    Submission[] public submissions;
    Offer[] public offers;

    address public validatorsContract;

    event SubmissionAccepted(
        uint256 indexed submissionIndex,
        uint256 indexed collectionIndex
    );
    event SubmissionRejected(
        uint256 indexed submissionIndex,
        uint256 indexed collectionIndex,
        string reason
    );

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
        require(validators.validatorStatus(_validator) == ValidatorStatus.Active, "Invalid validator");
        require(
            _maxParticipants > 0,
            "Max participants must be greater than zero"
        );

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
        require(
            _collectionIndex < collections.length,
            "Invalid collection index"
        );
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

    function acceptSubmission(uint256 _submissionIndex) public {
        require(
            _submissionIndex < submissions.length,
            "Invalid submission index"
        );
        Submission storage submission = submissions[_submissionIndex];

        require(
            msg.sender == collections[submission.collectionIndex].validator,
            "Sender is not the validator of the collection"
        );
        require(
            submission.status == SubmissionStatus.Initial,
            "Submission status is not initial"
        );

        submission.status = SubmissionStatus.Accepted;

        uint256 collectionIndex = submission.collectionIndex;
        Collection storage collection = collections[collectionIndex];
        uint256 amountToSend = collection.deposit / collection.maxParticipants;

        // Transfer the calculated amount to the submitter
        payable(submission.submitter).transfer(amountToSend);

        emit SubmissionAccepted(
            _submissionIndex,
            submissions[_submissionIndex].collectionIndex
        );
    }

    function rejectSubmission(
        uint256 _submissionIndex,
        string memory _reason
    ) public {
        require(
            _submissionIndex < submissions.length,
            "Invalid submission index"
        );
        Submission storage submission = submissions[_submissionIndex];

        require(
            msg.sender == collections[submission.collectionIndex].validator,
            "Sender is not the validator of the collection"
        );
        require(
            submission.status == SubmissionStatus.Initial,
            "Submission status is not initial"
        );

        submission.status = SubmissionStatus.Rejected;

        emit SubmissionRejected(
            _submissionIndex,
            submissions[_submissionIndex].collectionIndex,
            _reason
        );
    }

    function createOffer(
        uint256 _collectionIndex,
        string memory _uri,
        bytes32 _publicKey
    ) public payable {
        require(
            _collectionIndex < collections.length,
            "Invalid collection index"
        );

        Offer memory newOffer = Offer({
            collectionIndex: _collectionIndex,
            deposit: msg.value,
            requestURI: _uri,
            publicKey: _publicKey,
            status: OfferStatus.Pending,
            resultURI: ""
        });

        offers.push(newOffer);
    }
}
