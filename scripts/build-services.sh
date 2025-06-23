#!/bin/bash

# MSA 서비스 빌드 및 Docker 이미지 생성 스크립트

set -e

echo "🏗 MSA 서비스 빌드 시작..."

# Harbor 레지스트리 설정
REGISTRY="localhost:30002"
NAMESPACE="msa"

# 각 서비스 빌드
services=("user-service" "order-service" "product-service" "gateway-service")

for service in "${services[@]}"; do
    echo "📦 $service 빌드 중..."
    
    cd "services/$service"
    
    # Maven 빌드
    if [ -f "pom.xml" ]; then
        echo "🔨 Maven 빌드: $service"
        mvn clean package -DskipTests
        
        # Docker 이미지 빌드
        echo "🐳 Docker 이미지 빌드: $service"
        docker build -t "$REGISTRY/$NAMESPACE/$service:latest" .
        docker build -t "$REGISTRY/$NAMESPACE/$service:1.0.0" .
        
        echo "✅ $service 빌드 완료"
    else
        echo "⚠️ $service: pom.xml이 없습니다. 건너뜁니다."
    fi
    
    cd "../.."
done

# 프론트엔드 빌드
echo "🌐 Frontend 서비스 빌드 중..."
cd "services/frontend-service"

if [ -f "package.json" ]; then
    echo "📦 npm 빌드: frontend-service"
    
    # 기본 React 파일들 생성 (실제 개발 시에는 이 부분 제거)
    mkdir -p public src/components
    
    # public/index.html 생성
    cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>MSA Frontend</title>
</head>
<body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
</body>
</html>
EOF
    
    # src/index.js 생성
    cat > src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
EOF
    
    # 기본 컴포넌트들 생성
    cat > src/components/Dashboard.js << 'EOF'
import React from 'react';
import { Card, Row, Col, Statistic } from 'antd';

function Dashboard() {
    return (
        <div>
            <h1>Dashboard</h1>
            <Row gutter={16}>
                <Col span={8}>
                    <Card>
                        <Statistic title="Total Users" value={112} />
                    </Card>
                </Col>
                <Col span={8}>
                    <Card>
                        <Statistic title="Total Orders" value={93} />
                    </Card>
                </Col>
                <Col span={8}>
                    <Card>
                        <Statistic title="Total Products" value={28} />
                    </Card>
                </Col>
            </Row>
        </div>
    );
}

export default Dashboard;
EOF
    
    cat > src/components/UserManagement.js << 'EOF'
import React from 'react';
import { Table, Button } from 'antd';

function UserManagement() {
    const columns = [
        { title: 'ID', dataIndex: 'id', key: 'id' },
        { title: 'Name', dataIndex: 'name', key: 'name' },
        { title: 'Email', dataIndex: 'email', key: 'email' },
        { title: 'Action', key: 'action', render: () => <Button>Edit</Button> }
    ];
    
    const data = [
        { id: 1, name: 'John Doe', email: 'john@example.com' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
    ];
    
    return (
        <div>
            <h1>User Management</h1>
            <Table columns={columns} dataSource={data} />
        </div>
    );
}

export default UserManagement;
EOF
    
    # 나머지 컴포넌트도 비슷하게 생성
    cp src/components/UserManagement.js src/components/OrderManagement.js
    cp src/components/UserManagement.js src/components/ProductManagement.js
    
    # CSS 파일 생성
    cat > src/App.css << 'EOF'
.App {
    text-align: center;
}
EOF
    
    # Docker 이미지 빌드
    echo "🐳 Docker 이미지 빌드: frontend-service"
    docker build -t "$REGISTRY/$NAMESPACE/frontend-service:latest" .
    docker build -t "$REGISTRY/$NAMESPACE/frontend-service:1.0.0" .
    
    echo "✅ frontend-service 빌드 완료"
else
    echo "⚠️ frontend-service: package.json이 없습니다. 건너뜁니다."
fi

cd "../.."

echo ""
echo "✅ 모든 서비스 빌드 완료!"
echo "🐳 생성된 Docker 이미지:"
docker images | grep "$REGISTRY/$NAMESPACE"

echo ""
echo "🚀 다음 단계:"
echo "  1. Harbor에 로그인: docker login $REGISTRY -u admin -p Harbor12345"
echo "  2. 이미지 푸시: ./scripts/push-images.sh"
echo "  3. 서비스 배포: ./scripts/deploy-services.sh" 