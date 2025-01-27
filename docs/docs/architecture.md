# System Architecture

## Core Components

### Chat Interface System
- **Location**: `app/components/chat/*`
- Responsibilities:
  - Real-time AI chat functionality
  - Multi-provider LLM integration (OpenAI, Anthropic, HuggingFace, etc.)
  - Code execution visualization via WebContainer
  - Session state management

### WebContainer Runtime
- **Location**: `app/lib/webcontainer`
- Key Features:
  - Secure code execution environment
  - Browser-based IDE integration
  - Real-time preview capabilities
  - Filesystem emulation for project workspaces

### LLM Gateway Service
- **Location**: `app/routes/api.llmcall.ts`
- Architecture:
  - Unified API facade for multiple providers
  - Token management via `APIKeyManager.tsx`
  - Streaming response handling
  - Fallback mechanisms for model availability

## Infrastructure
```mermaid
graph TD
    A[Browser Client] --> B{Cloudflare Worker}
    B --> C[WebContainer Runtime]
    B --> D[LLM Gateway Service]
    
    subgraph LLM_Gateway [LLM Gateway Service]
        D --> D1[API Gateway Facade<br>app/routes/api.llmcall.ts]
        D1 --> D2[Token Manager<br>app/components/chat/APIKeyManager.tsx]
        D2 --> D3[Validation Service<br>app/lib/api/validateRequest.ts]
        D3 --> D4[Provider Adapter<br>app/utils/constants.ts DEFAULT_PROVIDERS]
        D4 --> D5[Fallback Router<br>app/lib/api/fallback.ts]
    end
    
    subgraph WebContainer [WebContainer Runtime]
        C --> C1[Execution Engine]
        C1 --> C2[Filesystem Emulation]
        C2 --> C3[Preview Server]
        C3 --> C4[Security Sandbox]
    end
    
    D5 --> E[(LLM Providers)]
    C --> F[(Project Workspaces)]
    
    %% Security Architecture
    D2 -.-> G[(API Key Store)]
    D3 -.-> H[(Request Validation Rules)]
    C4 -.-> I[(Isolation Policies)]
    
    %% Response Flow
    D5 -->|Streaming Response| B
    C3 -->|Execution Results| B
    B -->|Rendered Output| A
    
    %% Error Handling
    D5 -->|Fallback| J[Alternative Provider]
    C1 -->|Error| K[Error Recovery]
```

## Data Flow
1. User input processed through `Chat.client.tsx`
2. Request routed via `api.llmcall.ts` to appropriate LLM
3. Code responses executed in WebContainer runtime
4. Results streamed back through `Messages.client.tsx`

## Implementation Details

### Provider Integrations
- **Icon Management**: SVG assets in `public/icons/` mapped to LLM providers (see `public/icons/OpenAI.svg` example)
- **Type Definitions**: `app/types/model.ts` defines ProviderConfiguration interface
- **Configuration**: `app/utils/constants.ts` contains DEFAULT_PROVIDERS array
- **API Contracts**: `app/types/actions.ts` defines LLMRequest/Response types
- **Security**: `app/lib/api/validateRequest.ts` handles request authentication

### API Contracts
```ts
// From app/types/actions.ts
interface LLMRequest {
  provider: string;
  model: string;
  messages: ChatMessage[];
  temperature: number;
}

// From app/routes/api.llmcall.ts
export const loader: LoaderFunction = async ({ request }) => {
  const payload = await validateRequest(request);
  return handleLLMCall(payload);
};
```

### Security Architecture
- API key management via `app/components/chat/APIKeyManager.tsx`
- Request validation in `app/lib/api/validateRequest.ts`
- WebContainer isolation policies in `app/lib/webcontainer/`
