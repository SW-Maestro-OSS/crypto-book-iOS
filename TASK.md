# TASK.md

## Goal
    DataFactory 를 없애는 쪽으로 리팩토링 하고 싶다. 
## Scope
- 포함할 것
- Data 폴더에 있는 것은 모두 변경해도 된다. 

## Files
- Data 폴더

## Constraints
- 전체 TCA, Clean 아키텍쳐 구조를 준수할 것 

## Acceptance Criteria
- DataFactory 파일이 없어지는 것 
- DataSource 형태로 변경되어 BinanceAllMarketTickersWebSocketService 이게 여전히 public 이 아니어도 쓸 수 있게 하도록 
