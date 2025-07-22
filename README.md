# 🧠 Mental Health Support DAO

A decentralized autonomous organization focused on mental health support through community-driven content sharing, peer support, and professional assistance.

## 🎯 Overview

The Mental Health Support DAO creates a tokenized ecosystem where:
- 📝 Users share mental health tips, stories, and peer support content
- 🗳️ Community votes on content value to release token rewards
- 🔒 Anonymous contributions are supported for privacy
- 👩‍⚕️ Licensed mental health professionals can be verified and rewarded
- 🏛️ DAO governance ensures quality control and fair distribution

## ✨ Key Features

### 📊 Content Submission & Voting
- Submit mental health content with title and content hash
- Anonymous submission option for privacy
- Community voting system (1-10 scale)
- Automatic reward distribution based on votes

### 🏆 Token Economy
- **MH Support Token**: Native fungible token for rewards
- Vote-based reward calculation (votes × multiplier)
- Minimum vote threshold for reward eligibility
- Configurable reward parameters

### 👨‍⚕️ Professional Network
- Professional registration with specialization
- Owner-verified professional status
- Direct professional rewards system
- Verified professional tracking

### 🏛️ DAO Governance
- Member registration and contribution tracking
- Voting power management
- Content moderation capabilities
- Configurable voting periods and thresholds

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) installed
- Stacks blockchain environment

### Installation
```bash
git clone <repository-url>
cd Mental-Health-Support-DAO
clarinet check
```

## 📖 Usage Guide

### 🔧 Core Functions

#### Content Management
```clarity
;; Submit content
(submit-content "Mindfulness Tips" "hash123..." true)

;; Vote on content (1-10 scale)
(vote-on-content u1 u8)

;; Finalize voting and distribute rewards
(finalize-voting u1)
```

#### Professional Services
```clarity
;; Register as mental health professional
(register-professional "Clinical Psychology")

;; Verify professional (owner only)
(verify-professional 'SP1234...)

;; Reward professional
(reward-professional 'SP1234... u100)
```

#### DAO Participation
```clarity
;; Join the DAO
(join-dao)

;; Transfer tokens
(transfer 'SP5678... u50)
```

### 📊 Read-Only Functions
```clarity
;; Check token balance
(get-balance 'SP1234...)

;; Get content information
(get-content u1)

;; Check professional status
(get-professional-info 'SP1234...)

;; View DAO member information
(get-dao-member-info 'SP1234...)
```

### 🛡️ Admin Functions (Owner Only)
```clarity
;; Moderate content
(moderate-content u1 "approved")

;; Update voting period (blocks)
(update-voting-period u2880)

;; Update reward multiplier
(update-reward-multiplier u15)

;; Emergency pause content
(emergency-pause u1)
```

## ⚙️ Configuration

### Default Parameters
- **Voting Period**: 1440 blocks (~24 hours)
- **Minimum Vote Threshold**: 5 votes
- **Reward Multiplier**: 10 tokens per vote
- **Vote Range**: 1-10 scale

### Content Statuses
- `"pending"` - Newly submitted, voting active
- `"rewarded"` - Voting complete, rewards distributed
- `"paused"` - Emergency pause by admin
- `"moderated"` - Admin moderated content

## 🔐 Security Features

- ✅ Owner-only administrative functions
- ✅ Vote spam prevention (one vote per user per content)
- ✅ Professional verification system
- ✅ Emergency pause functionality
- ✅ Input validation and error handling

## 🎭 Privacy & Anonymity

- Anonymous content submission option
- Content author privacy protection
- Hash-based content storage (off-chain content)
- Privacy-preserving voting system

## 🧪 Testing

```bash
npm install
npm test
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- 📧 Open an issue on GitHub
- 💬 Join our community discussions
- 📚 Check the [Stacks documentation](https://docs.stacks.co)

## 🌟 Acknowledgments

- Built with ❤️ for mental health awareness
- Powered by Stacks blockchain
- Community-driven development

---

**🌈 Together, we can break the stigma around mental health and build supportive communities!**
