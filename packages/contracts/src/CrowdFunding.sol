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
        mapping(address contributor => uint256 amount) contributors;
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

    event ContributionReceived(uint256 indexed campaign_id, address indexed contributor, uint256 amount);

    /**
     * ERRORS
     */
    error CrowdFunding__CannotBeZero();
    error CrowdFunding__InvalidDeadlineDate();
    error CrowdFunding__EmptyString();
    error CrowdFunding__CampaignDoesNotExist();
    error CrowdFunding__CampaignFinished();

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

    modifier campaignExists(uint256 campaign_id) {
        if (campaign_id >= campaignCount) {
            revert CrowdFunding__CampaignDoesNotExist();
        }
        _;
    }

    modifier beforeDeadline(uint256 campaign_id) {
        if (s_campaigns[campaign_id].deadline < block.timestamp) {
            revert CrowdFunding__CampaignFinished();
        }
        _;
    }

    /**
     * FUNCTIONS
     */
    constructor() {}

    /**
     * @notice Create a new campaign
     * @param _name campaign name
     * @param _description campaign description
     * @param _goal campaign goal
     * @param _deadline campaign deadline
     */
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

    /**
     * @notice Contribute to a campaign
     * @param campaign_id Campaign id
     */
    function contribute(uint256 campaign_id)
        external
        payable
        campaignExists(campaign_id)
        beforeDeadline(campaign_id)
        moreThanZero(msg.value)
    {
        Campaign storage campaign = s_campaigns[campaign_id];
        campaign.contributors[msg.sender] += msg.value;
        campaign.raised += msg.value;
        emit ContributionReceived(campaign_id, msg.sender, msg.value);
    }
}
