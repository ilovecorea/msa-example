import { AppstoreOutlined, ShoppingOutlined, UserOutlined } from '@ant-design/icons';
import { Layout, Menu, Typography } from 'antd';
import React from 'react';
import { Route, BrowserRouter as Router, Routes } from 'react-router-dom';
import './App.css';
import Dashboard from './components/Dashboard';
import OrderManagement from './components/OrderManagement';
import ProductManagement from './components/ProductManagement';
import UserManagement from './components/UserManagement';

const { Header, Content, Footer, Sider } = Layout;
const { Title } = Typography;

const menuItems = [
  {
    key: '1',
    icon: <AppstoreOutlined />,
    label: 'Dashboard',
    path: '/'
  },
  {
    key: '2',
    icon: <UserOutlined />,
    label: 'Users',
    path: '/users'
  },
  {
    key: '3',
    icon: <ShoppingOutlined />,
    label: 'Orders',
    path: '/orders'
  },
  {
    key: '4',
    icon: <AppstoreOutlined />,
    label: 'Products',
    path: '/products'
  }
];

function App() {
  return (
    <Router>
      <Layout style={{ minHeight: '100vh' }}>
        <Sider collapsible>
          <div style={{ height: 32, margin: 16, background: 'rgba(255, 255, 255, 0.2)' }} />
          <Menu theme="dark" defaultSelectedKeys={['1']} mode="inline">
            {menuItems.map(item => (
              <Menu.Item key={item.key} icon={item.icon}>
                <a href={item.path}>{item.label}</a>
              </Menu.Item>
            ))}
          </Menu>
        </Sider>
        <Layout>
          <Header style={{ padding: 0, background: '#fff' }}>
            <Title level={2} style={{ margin: '0 24px', lineHeight: '64px' }}>
              MSA Management System
            </Title>
          </Header>
          <Content style={{ margin: '16px' }}>
            <div style={{ padding: 24, minHeight: 360, background: '#fff' }}>
              <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/users" element={<UserManagement />} />
                <Route path="/orders" element={<OrderManagement />} />
                <Route path="/products" element={<ProductManagement />} />
              </Routes>
            </div>
          </Content>
          <Footer style={{ textAlign: 'center' }}>
            MSA Example ©2024 Created with Spring Boot & React
          </Footer>
        </Layout>
      </Layout>
    </Router>
  );
}

export default App; 