// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract CrowdFunding {
    /**
     * TYPE DECLARATIONS
     */
    struct Campaign {
        address owner;
        string name;
        string description;
        uint256 goal;
        uint256 raised;
        uint256 deadline;
        bool isWithdrawn;
        mapping(address contributer => uint256 amount) contributors;
    }

    /**
     * STATE VARIABLES
     */
    uint256 campaignCount = 0;
    mapping(uint256 campaign_id => Campaign) public s_campaigns;

    /**
     * EVENTS
     */
    event CampaignCreated(
        uint256 indexed campaign_id,
        address indexed owner,
        string name,
        string description,
        uint256 goal,
        uint256 deadline
    );

    /**
     * ERRORS
     */
    error CrowdFunding__CannotBeZero();
    error CrowdFunding__InvalidDeadlineDate();
    error CrowdFunding__EmptyString();

    /**
     * Modifiers
     */
    modifier moreThanZero(uint256 value) {
        if (value <= 0) {
            revert CrowdFunding__CannotBeZero();
        }
        _;
    }

    modifier isNotEmptyString(string memory value) {
        if (bytes(value).length == 0) {
            revert CrowdFunding__EmptyString();
        }
        _;
    }

    /**
     * FUNCTIONS
     */
    constructor() {}

    function createCampaign(string memory _name, string memory _description, uint256 _goal, uint256 _deadline)
        external
        isNotEmptyString(_name)
        isNotEmptyString(_description)
        moreThanZero(_goal)
    {
        // check if the deadline is valid
        if (_deadline < block.timestamp) {
            revert CrowdFunding__InvalidDeadlineDate();
        }

        Campaign storage newCampaign = s_campaigns[campaignCount];

        // update the new campaign data
        newCampaign.owner = msg.sender;
        newCampaign.name = _name;
        newCampaign.description = _description;
        newCampaign.goal = _goal;
        newCampaign.raised = 0;
        newCampaign.deadline = _deadline;
        newCampaign.isWithdrawn = false;
        emit CampaignCreated(campaignCount, msg.sender, _name, _description, _goal, _deadline);
        campaignCount++;
    }
}
