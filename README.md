# MultiSigWallet

거래를 실행하기 위해 소유자의 특정 수의 확인이 필요한 다중 서명 지갑.
이는 단일 소유자가 거래를 단독으로 수행할 수 없도록 하여 지갑의 보안을 강화함.

### 주요 구성 요소

- **Owners**: 지갑을 관리할 수 있는 주소.
- **Required Confirmations**: 거래를 실행하는 데 필요한 확인 수.

### Structs

- **Transaction**: 실행할 거래를 나타냄.
  - `destination`: 거래가 전송될 주소.
  - `value`: 전송할 이더의 양.
  - `executed`: 거래가 실행되었는지 여부를 나타냄.
  - `data`: 거래의 데이터 페이로드.
  - `confirmations`: 받은 확인 수.

### Events

- `Deposit(address indexed sender, uint amount)`: 이더가 지갑에 입금될 때 발생.
- `Submission(uint indexed transactionId)`: 거래가 제출될 때 발생.
- `Confirmation(address indexed owner, uint indexed transactionId)`: 소유자가 거래를 확인할 때 발생.
- `Execution(uint indexed transactionId)`: 거래가 실행될 때 발생.
- `ExecutionFailure(uint indexed transactionId)`: 거래 실행이 실패할 때 발생.

### Modifiers

- **onlyOwner**: 지갑 소유자만 함수 호출을 허용.
- **transactionExists**: 거래가 존재하는지 확인.
- **confirmed**: 거래가 발신자에 의해 확인되었는지 확인.
- **notConfirmed**: 거래가 발신자에 의해 이미 확인되지 않았는지 확인.
- **notExecuted**: 거래가 실행되지 않았는지 확인.

### Functions

- **constructor**: 제공된 소유자 및 필요한 확인 수로 계약을 초기화.
- **receive**: 들어오는 이더를 처리하기 위한 폴백 함수.
- **submitTransaction**: 소유자가 거래를 제출할 수 있도록 함.
- **confirmTransaction**: 소유자가 거래를 확인할 수 있도록 함.
- **executeTransaction**: 필요한 확인 수가 충족되면 거래를 실행.
- **getConfirmations**: 주어진 거래에 대한 확인 수를 반환.

